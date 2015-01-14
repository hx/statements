require 'time'

module Statements
  class Search

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def transactions
      @transactions ||= query.all
    end

    def debits
      transactions.select { |t| t.amount < 0 }
    end

    def credits
      transactions.select { |t| t.amount > 0 }
    end

    def total(collection = :transactions)
      __send__(collection).inject(0) { |sum, t| sum + t.amount }
    end

    private

    def query
      query = Transaction.order(input['order'])
      query = query.where(account_id: input['accounts'])
      query = query.where('posted_at > ? and posted_at < ?',
                          Time.parse(input['date_start']),
                          Time.parse(input['date_end']))
      query = query.where('amount < 0') if input['type'] == 'debits'
      query = query.where('amount > 0') if input['type'] == 'credits'
      text = input['search'].strip.downcase
      unless text.empty?
        words = text.split(/\s+/)
        query = query.where('lower(description) like ?', "%#{words.join '%'}%")
      end
      query
    end

  end
end
