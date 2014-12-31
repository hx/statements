module Statements
  class Cli

    def self.main(argv)
      Statements::Database.new
      puts Transaction.count
    end

  end
end
