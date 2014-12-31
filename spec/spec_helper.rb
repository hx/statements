$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['DB_PATH'] = ':memory:'

require 'statements'
require 'pathname'

def fixture(name)
  Pathname(File.expand_path('../fixtures', __FILE__)).join name
end
