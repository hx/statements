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

    def self.for_file(file)
      file = file.to_s
      pages = (file =~ /\.pdf$/i) ? PdfReader.read(file) : File.read(file).split(/-{5,}/)
      classes.each do |klass|
        reader = klass.new(pages)
        return reader if reader.valid?
      end
      nil
    end

    def self.read_dir(dir)
      base = Pathname(dir).realpath
      Dir[base.join('**/*.{pdf,txt}')].each do |path|
        rel_path = Pathname(path).relative_path_from(base)
        begin
          doc = Document.find_or_initialize_by(path: rel_path.to_s)
          doc.scan base: base
        rescue => e
          puts "error: #{e.class.name} #{e.message}\n  #{e.backtrace.join "\n  "}"
        end
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
      index = 0
      result = []
      pages.each.with_index do |page, page_index|
        page.scan(cell_pattern).each do |cells|
          result << Transaction.new(document_line: index += 1).tap do |transaction|
            args = [cells, transaction, page_index]
            arity = method(:parse_cells).arity
            parse_cells *args[0..(arity - 1)]
          end
        end
      end
      result
    end

  end
end
