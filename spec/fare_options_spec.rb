require 'spec_helper'
 
describe FareOptions do
  before :each do
    @options = FareOptions.new({'Gopal' => 30.30, 'Opal' => 10.10, 'Nopal' => 20.20})
  end

  describe '#cheapest' do
    it 'returns the cheapest fare' do
      @options.cheapest.should == 'Opal'
    end

    it 'returns the cheapest non-Opal fare' do
      @options.cheapest(false).should == 'Nopal'
    end
  end

  describe '#table' do
    it 'returns fares in as Google Chart data table, in ascending order, lowest highlighted' do
      @options.table.should == [
        ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
        ['Opal', 10.10, '#4582EC', '$10.10'],
        ['Nopal', 20.20, 'gray', '$20.20'],
        ['Gopal', 30.30, 'gray', '$30.30']
      ]
    end
  end

  describe '#result' do
    it 'returns processed fare information' do
      @options.result.should ==  {
        "winner"=>"Opal",
        "alternative"=>"Nopal",
        "savings"=>{
          "week"=>@options.savings(1),
          "year"=>@options.savings(52)
        },
        "table"=>@options.table
      }
    end
  end
end
