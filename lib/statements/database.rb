require 'active_record'

module Statements
  class Database

    def initialize(path = nil)
      @path = File.expand_path(path || ENV['DB_PATH'] || Dir.pwd + '/statements.sqlite3')
      ActiveRecord::Base.establish_connection(
          adapter: 'sqlite3',
          database: @path
      )
      ActiveRecord::Migrator.migrate migrations_dir
    end

    private

    def migrations_dir
      @migrations_dir ||= Statements::ROOT.join('lib/statements/migrations').to_s
    end
  end
end
