require 'sinatra/base'

module Statements
  class Server < Sinatra::Base
    get('/') { redirect 'html/index.html' }
    not_found { [404, 'Not found'] }
  end
end
