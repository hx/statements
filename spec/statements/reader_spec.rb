module Statements
  describe Reader do

    describe 'classes' do

      it 'should be a list of reader classes' do
        expect(Reader.classes).to include Reader::StGeorgeCreditCard
      end

      it 'should not include any non-reader classes' do
        expect(Reader.classes.reject { |x| x < Reader }).to be_empty
      end

    end

  end
end