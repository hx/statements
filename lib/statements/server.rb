require 'json'

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

    def post_search_html(request)
      html 'blah'
    end

  end
end
