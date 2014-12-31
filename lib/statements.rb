require 'pathname'

require 'statements/version'
require 'statements/cli'
require 'statements/reader'
require 'statements/database'

require 'statements/models/transaction'

module Statements
  ROOT = Pathname File.expand_path('../..', __FILE__)
end
