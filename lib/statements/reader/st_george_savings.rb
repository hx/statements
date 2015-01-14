require_relative 'common/st_george'
require 'time'
require 'bigdecimal'

module Statements
  class Reader
    class StGeorgeSavings < self
      include StGeorge

      DATED_DESCRIPTIONS = [
          'INTERNET WITHDRAWAL',
          'INTERNET DEPOSIT',
          'ATM DEPOSIT',
          'ATM WITHDRAWAL',
          'VISA PURCHASE',
          'VISA PURCHASE O/SEAS',
          'EFTPOS PURCHASE'
      ]

      def valid?
        st_george? && pages.first =~ /BSB\s+Number\s+112-879/
      end

      def self.cell_pattern
        @cell_pattern ||= %r`^
           (\d\d\s+)
           ([A-Z]{3}\s+)
           (.+?)
           ([\d,]+\.\d\d) \s+
           ([\d,]+\.\d\d) \s*
           $
           ((?:
             \n+\040[^\r\n]+
           )*)
        `x
      end

      def parse_cells(cells, tx, page_index)

        # Examples cells:
        # ['17 ', 'NOV  ', 'LINE 1  ', '12,345.67', '50.00', "\n  LINE 2\n  Line 3"]

        tx.posted_at = parse_date(cells[0..1].join)

        is_debit = is_debit?(cells, page_index)
        debit_factor = is_debit ? -1 : 1

        tx.amount  = BigDecimal(cells[3].delete ',') * debit_factor
        tx.balance = BigDecimal(cells[4].delete ',')

        # TODO: negative balances

        lines = [cells[2].strip]
        lines += cells[5].strip.split(/\s*\n\s*/) if cells[5]
        lines.each { |line| line.gsub! /\s+/, ' ' }
        lines.reject! { |line| line.start_with? 'SUB TOTAL CARRIED FORWARD TO NEXT PAGE' }

        tx.description = lines.join("\n")

        if lines.first =~ %r`^(.+?) (?:(\d\d)/(\d\d)/\d\d|(\d\d\w{3}) \d\d:\d\d)$` && DATED_DESCRIPTIONS.include?($1)
          description = $1
          tx.transacted_at = $2 ? parse_date("2000-#{$3}-#{$2}") : parse_date($4)
          if description.end_with?('O/SEAS') && lines.last =~ /\b([A-Z]{3}) ([\d,]+\.\d\d)$/
            tx.foreign_currency = $1
            tx.foreign_amount = BigDecimal($2.delete ',') * debit_factor
          end
        end

        tx.transacted_at ||= tx.posted_at
        
        tx.set_account account_name, account_number
      end

      def is_debit?(cells, page_index)
        amount_offset = cells[0..2].map(&:length).inject(:+)
        amount_center = amount_offset + cells[3].length / 2
        amount_center < credit_threshold(page_index)
      end

      def credit_threshold(page)
        (@credit_thresholds ||= {})[page] ||= find_credit_threshold(page)
      end

      def find_credit_threshold(page)
        lengths = pages[page].scan(/^(Date\s+Transaction\s+De\w+\s+)(Debit\s+Credit)/).first.map(&:length)
        lengths.first + lengths.last / 2
      end

      def account_name
        @account_name ||= document[/^\s*Statement\s+of\s+Account\s*((?:\S\s{0,4})+)/, 1].strip
      end

    end
  end
end
