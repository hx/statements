require 'pathname'

module Statements
  ROOT = Pathname File.expand_path('../..', __FILE__)
end

require 'statements/version'
require 'statements/cli'
require 'statements/reader'
require 'statements/database'
require 'statements/pdf_reader'
require 'statements/server'
require 'statements/search'

require 'statements/models/transaction'
require 'statements/models/account'
require 'statements/models/document'
