require 'spec_helper'
 
class TestFare < Fare
  def compute
    17
  end

  def name
    "TestName"
  end
end

describe Comparison do
  describe 'when computing' do
    before :each do
      @options = Comparison.new
      stub(@options).fare_types { [TestFare] }
    end

    describe '#compute' do
      it 'returns a hash of names and fares' do
        dummy_data = [{}]
        @options.compute(dummy_data).all.should == {'TestName' => 17}
      end
    end
  end

  describe 'with results already computed' do
    before :each do
      @options = Comparison.new({'Gopal' => 30.30, 'Opal' => 10.10, 'Nopal' => 20.20})
    end

    describe '#cheapest' do
      it 'returns the cheapest fare' do
        @options.cheapest.should == 'Opal'
      end

      it 'returns the cheapest non-Opal fare' do
        @options.cheapest(false).should == 'Nopal'
      end
    end

    describe '#savings' do
      it 'returns weekly savings' do
        @options.savings.should == 10.1
      end

      it 'returns yearly savings' do
        @options.savings(52).should be_within(0.01).of(525.2) 
      end
    end

    describe '#table' do
      it 'returns fares in as Google Chart data table, in ascending order, Opal highlighted' do
        @options.table.should == [
          ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
          ['Opal', 10.10, '#4582EC', '$10.10'],
          ['Nopal', 20.20, 'gray', '$20.20'],
          ['Gopal', 30.30, 'gray', '$30.30']
        ]
      end

      it 'highlights both Opal and the lowest fare if different' do
        Comparison.new({'Gopal' => 30.30, 'Opal' => 20.20, 'Nopal' => 10.10}).table.should == [
          ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
          ['Nopal', 10.10, '#3FAD46', '$10.10'],
          ['Opal', 20.20, '#4582EC', '$20.20'],
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
          "table"=>@options.table,
          "stats"=>{}
        }
      end
    end
  end
end
