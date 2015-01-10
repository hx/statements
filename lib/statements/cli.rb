require 'thin'

module Statements
  class Cli

    def self.main(pwd, argv)
      Statements::Database.new "#{pwd}/statements.sqlite3"
      Statements::Reader.read_dir pwd
      Thin::Server.start '0.0.0.0', 57473 do
        map('/q') { run Server.new }
        use Rack::Static, urls: [''], root: "#{ROOT}/lib/html", index: 'index.html'
        run Server
      end
    end

  end
end
