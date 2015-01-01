$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['DB_PATH'] = ':memory:'
ENV['DB_LOG'] = File.expand_path('../../log/test.log', __FILE__)

require 'statements'
require 'pathname'

def fixture(name)
  Pathname(File.expand_path('../fixtures', __FILE__)).join name
end
