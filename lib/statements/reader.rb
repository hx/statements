require 'forwardable'
require 'pdf/reader'

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

    def self.for_file(file)
      file = file.to_s
      pages = (file =~ /\.pdf$/i) ? PDF::Reader.new(file).pages.map(&:text) : [File.read(file)]
      classes.each do |klass|
        reader = klass.new(pages)
        return reader if reader.valid?
      end
    end

    attr_reader :pages, :document

    delegate [:include?, :scan] => :document

    def initialize(pages)
      @pages = pages
      @document = pages.join("\n").freeze
    end

    def cell_pattern
      self.class.cell_pattern
    end

    def self.cell_pattern
      raise NotImplementedError
    end

    def transactions
      @transactions ||= search_for_transactions
    end

    def search_for_transactions
      scan(cell_pattern).map.with_index do |cells, index|
        Transaction.new(document_line: index + 1).tap do |transaction|
          parse_cells cells, transaction
        end
      end
    end

  end
end
