require_relative 'common/st_george'
require 'time'
require 'big_decimal'

module Statements
  class Reader
    class StGeorgeCreditCard < self
      include StGeorge

      def valid?
        st_george? && pages.first.include?('MASTERCARD Statement')
      end

      def self.cell_patterns
        @cell_patterns ||= [
            /\d{1,2}\s+[A-Z][a-z]/,
            /\d{1,2}\s+[A-Z][a-z]/,
            /.+?/,
            /\$\d+\.\d\d(?:\s+CR)?/,
            /\$\d+\.\d\d(?:\s+CR)?/,
            /(?:\n\s+\d+\.\d\d\s+[A-Z]{3})?/
        ]
      end

      def parse_cells(cells)
        [:posted_at, :transacted_at].each.with_index do |attr, index|
          date = Time.parse(cells[index])
          set attr, Time.new (date.month == 12 ? years.first : years.last), date.month, date.day
        end
        description cells[2]
        {amount: 3, balance: 4}.each do |attr, index|
          number = BigDecimal cells[index][/\d+\.\d+/]
          credit = cells[index].end_with? 'CR'
          number *= -1 unless credit
          set attr, number
        end
        foreign = cells[5]
        if foreign
          foreign_amount BigDecimal foreign[0..-5]
          foreign_currency foreign[-3..-1]
        end
      end

      private

      def years
        @years ||= (pages.first =~ %r`Statement Period\s+\d\d/\d\d/(\d{4})\s+to\s+\d\d/\d\d/(\d{4})` && [$1.to_i, $2.to_i])
      end

    end
  end
end
