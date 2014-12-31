module Statements
  class Cli

    def self.main(pwd, argv)
      Statements::Database.new "#{pwd}/statements.sqlite3"
      Statements::Reader.read_dir pwd
    end

  end
end
