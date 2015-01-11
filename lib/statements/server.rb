require 'json'
require 'erb'

module Statements
  class Server

    def initialize

    end

    def call(env)
      request = Rack::Request.new(env)
      verb = request.request_method.downcase
      path = request.path_info[1..-1].split('/')
      handler_name = "#{verb}_#{path.first || 'index'}".gsub('.', '_')
      args = [request] + path[1..-1]
      method = respond_to?(handler_name) && method(handler_name)
      if method && method.arity == args.length
        __send__ handler_name, *args
      else
        [404, {}, ['Not found']]
      end
    end

    # noinspection RubyStringKeysInHashInspection
    def serve(type, str)
      [200, {'Content-Type' => type, 'Content-Length' => str.length.to_s}, [str]]
    end

    def json(data)
      serve 'application/json', JSON.generate(data, quirks_mode: true)
    end

    def js(script)
      serve 'application/x-javascript', script
    end

    def html(html)
      serve 'text/html', html
    end

    def get_accounts_js(request)
      js "window.accounts = #{Account.to_json}"
    end

    def self.render(template, obj = nil)
      @templates ||= {}
      @templates[template] ||= ERB.new(File.read File.expand_path("../views/#{template}.erb", __FILE__))
      @templates[template].result (obj || self).instance_eval { binding }
    end

    def post_search_html(request)
      input = JSON.parse(request.body.read)
      query = Transaction.order(input['order'])
      query = query.where(account_id: input['accounts'])
      query = query.where('posted_at > ? and posted_at < ?',
                          Time.parse(input['date_start']),
                          Time.parse(input['date_end']))
      query = query.where('amount < 0') if input['type'] == 'debits'
      query = query.where('amount > 0') if input['type'] == 'credits'
      text = input['search'].strip.downcase
      unless text.empty?
        words = text.split(/\s+/)
        query = query.where('lower(description) like ?', "%#{words.join '%'}%")
      end
      transactions = query.all
      html self.class.render 'search', OpenStruct.new(transactions: transactions)
    end

  end
end
