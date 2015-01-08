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

      shared_examples 'account' do |base, name, number|

        subject { Reader.for_file fixture "#{base}.txt" }

        let(:expected) { YAML.load fixture("#{base}.yml").read }

        it 'should have the right number of transactions' do
          expect(subject.transactions.length).to be expected.length
        end

        it 'should have matching details' do
          expected.each.with_index do |e, index|
            t = subject.transactions[index]
            expect(t.account.name).to eq name
            expect(t.account.number).to eq number
            e.each do |field, value|
              value = value.strip if String === value
              puts "#{field} : #{value}"
              if field.end_with? '_at'
                expect(t[field]).to eq Time.parse(value)
              else
                expect(t[field]).to eq value
              end
            end
          end
        end

      end

      [
          ['st_george_credit_card', 'VERTIGO MASTERCARD', '1111 2222 3333 4444'],
          ['st_george_savings', 'COMPLETE FREEDOM', '12481632']
      ].each do |args|
        context "on #{args.first}" do
          include_examples 'account', *args
        end
      end

    end

  end
end