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
      serve 'text/html; charset=UTF-8', html
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
      html self.class.render 'search', Search.new(JSON.parse request.body.read)
    end

    def post_colour_json(request)
      input = JSON.parse(request.body.read)
      transaction = Transaction.find(input['id']) rescue false
      if transaction
        transaction.colour = input['colour']
        transaction.save
        json success: true
      else
        400
      end
    end

  end
end
