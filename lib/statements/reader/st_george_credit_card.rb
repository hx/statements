require_relative 'common/st_george'
require 'time'
require 'bigdecimal'

module Statements
  class Reader
    class StGeorgeCreditCard < self
      include StGeorge

      def valid?
        st_george? && pages.first.include?('Credit Limit')
      end

      def self.cell_pattern
        @cell_pattern ||= %r`^
          \s* (\d{1,2}\s+[A-Z][a-z]{2})
          \s* (\d{1,2}\s+[A-Z][a-z]{2})
          \s* (.+?)
          \s* (\$[\d,]+\.\d\d(?:\s+CR)?)
          \s* (\$[\d,]+\.\d\d(?:\s+CR)?)
          \s* (\n\s+\d+\.\d\d\s+[A-Z]{3})?
          \s*$
        `x
      end

      def parse_cells(cells, tx)
        [:posted_at, :transacted_at].each.with_index do |attr, index|
          date = Time.parse(cells[index])
          tx[attr] = Time.new((date.month == 12 ? years.first : years.last), date.month, date.day)
        end
        tx.description = cells[2]
        {amount: 3, balance: 4}.each do |attr, index|
          number = BigDecimal cells[index][/[\d,]+\.\d+/].delete(',')
          credit = cells[index].end_with? 'CR'
          number *= -1 unless credit
          tx[attr] = number
        end
        foreign = cells[5]
        if foreign
          tx.foreign_amount = BigDecimal foreign[0..-5]
          tx.foreign_amount *= -1 if tx.amount < 0
          tx.foreign_currency = foreign[-3..-1]
        end
        tx.set_account account_name, account_number
      end

      def account_name
        @account_name ||= document[/^\s*(.+)\s*Statement\s*$/, 1].strip
      end

    end
  end
end
