require 'shellwords'

module Statements
  module PdfReader
    class << self

      def read(path)
        x = 0
        result = []
        loop do
          page = read_page(path, x += 1)
          break if page.chomp.empty?
          result << page
        end
        result
      end

      private

      def read_page(path, page)
        `#{pdftotext_path} -enc UTF-8 -table -q -f #{page} -l #{page} #{Shellwords.escape path} /dev/stdout`
      end

      def pdftotext_path
        unless @pdftotext_path
          @pdftotext_path = `which pdftotext`.chomp
          raise 'Could not find `pdftotext`. Please install Xpdf from http://www.foolabs.com/xpdf/download.html' if @pdftotext_path.empty?
        end
        @pdftotext_path
      end

    end
  end
end
