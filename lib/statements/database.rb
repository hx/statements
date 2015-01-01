require 'active_record'

module Statements
  class Database

    def initialize(path = nil)
      @path = ENV['DB_PATH'] || path
      ActiveRecord::Base.establish_connection(
          adapter: 'sqlite3',
          database: @path
      )
      ActiveRecord::Base.logger = Logger.new(ENV['DB_LOG']) if ENV['DB_LOG']
      ActiveRecord::Migrator.migrate migrations_dir
    end

    private

    def migrations_dir
      @migrations_dir ||= Statements::ROOT.join('lib/statements/migrations').to_s
    end
  end
end
