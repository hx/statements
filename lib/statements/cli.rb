require 'thin'

module Statements
  class Cli

    def self.main(pwd, argv)
      Statements::Database.new "#{pwd}/statements.sqlite3"
      Statements::Reader.read_dir pwd
      Thin::Server.start '0.0.0.0', 57473 do
        map('/html') { run Rack::Directory.new "#{ROOT}/lib/html" }
        run Server.new
      end
    end

  end
end
