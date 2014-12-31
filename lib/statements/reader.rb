require 'forwardable'

module Statements
  class Reader
    extend Forwardable

    class << self
      attr_reader :classes
    end

    unless classes
      Dir[Statements::ROOT.join('lib/statements/reader/*.rb')].each { |p| require p }
      @classes = constants.map { |n| const_get n }.select { |c| Class === c && c < Reader }
    end

    attr_reader :pages, :document

    delegate [:include?] => :document

    def initialize(pages)
      @pages = pages
      @document = pages.join("\n").freeze
    end

    def cell_patterns
      self.class.cell_patterns
    end

    def self.cell_patterns
      raise NotImplementedError
    end
  end
end
