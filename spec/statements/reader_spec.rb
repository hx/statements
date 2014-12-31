require 'yaml'
require 'time'

module Statements
  describe Reader do

    before :all do
      Statements::Database.new
    end

    subject { Reader.for_file fixture 'st_george_credit_card.txt' }

    describe 'classes' do

      it 'should be a list of reader classes' do
        expect(Reader.classes).to include Reader::StGeorgeCreditCard
      end

      it 'should not include any non-reader classes' do
        expect(Reader.classes.reject { |x| x < Reader }).to be_empty
      end

    end

    describe 'for_file' do

      it 'should choose a reader type by validity' do
        expect(subject).to be_a Reader::StGeorgeCreditCard
      end

    end

    describe 'instance methods' do

      it 'should provide an array of transactions based on the given document contents' do
        expect(subject.transactions).to be_an Array
        expect(subject.transactions).not_to be_empty
        expect(subject.transactions.reject { |i| Transaction === i }).to be_empty
      end

    end

    describe 'transactions' do # TODO put this somewhere else

      let(:expected) { YAML.load fixture('st_george_credit_card.yml').read }

      it 'should have the right number of transactions' do
        expect(subject.transactions.length).to be expected.length
      end

      it 'should have matching details' do
        expected.each.with_index do |e, index|
          t = subject.transactions[index]
          e.each do |field, value|
            if field.end_with? '_at'
              expect(t[field]).to eq Time.parse(value)
            else
              if field == 'foreign_currency'
                puts 123
              end
              expect(t[field]).to eq value
            end
          end
        end
      end

    end

  end
end