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
  describe "#new" do
    it "turns string keys into symbols" do
      data = [{"mode" => "a", "zombie" => "b", "time" => {"am" => "first", "pm" => "last"}}]
      comparison = Comparison.new(data)
      comparison.data.should == [{:mode => "a", :zombie => "b", :time => {:am => "first", :pm => "last"}}]
    end

    it "converts count, zone into numbers" do
      data = [{:mode => "z", :count => "69", :zone => "42"}]
      comparison = Comparison.new(data)
      comparison.data.should == [{:mode => "z", :count => 69, :zone => 42}]
    end

    it "sorts data by mode of travel" do
      data = [{:mode => :z}, {:mode => :a}, {:mode => :a}]
      comparison = Comparison.new(data)
      comparison.data.should == [{:mode => :a}, {:mode => :a}, {:mode => :z}]
    end
  end

  describe "#mode_string" do
    it "returns a string describing used modes of travel" do 
      Comparison.new([{:mode => 'camel'}, {:mode => 'tuktuk'}]).mode_string.should == 'camel+tuktuk'
    end
  end

  describe 'when computing' do
    before :each do
      @comparison = Comparison.new()
      stub(@comparison).fare_types { [TestFare] }
    end

    describe '#compute' do
      it 'returns a hash of names and fares' do
        @comparison.compute.all.should == {'TestName' => 17}
      end
    end
  end

  describe 'with results already computed' do
    before :each do
      @comparison = Comparison.new([], {'Gopal' => 30.30, 'Opal' => 10.10, 'Nopal' => 20.20})
    end

    describe '#cheapest' do
      it 'returns the cheapest fare' do
        @comparison.cheapest.should == 'Opal'
      end

      it 'returns the cheapest non-Opal fare' do
        @comparison.cheapest(false).should == 'Nopal'
      end
    end

    describe '#savings' do
      it 'returns weekly savings' do
        @comparison.savings.should == 10.1
      end

      it 'returns yearly savings' do
        @comparison.savings(52).should be_within(0.01).of(525.2) 
      end
    end

    describe '#table' do
      it 'returns fares in as Google Chart data table, in ascending order, Opal highlighted' do
        @comparison.table.should == [
          ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
          ['Opal', 10.10, '#4582EC', '$10.10'],
          ['Nopal', 20.20, 'gray', '$20.20'],
          ['Gopal', 30.30, 'gray', '$30.30']
        ]
      end

      it 'highlights both Opal and the lowest fare if different' do
        Comparison.new([], {'Gopal' => 30.30, 'Opal' => 20.20, 'Nopal' => 10.10}).table.should == [
          ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
          ['Nopal', 10.10, '#3FAD46', '$10.10'],
          ['Opal', 20.20, '#4582EC', '$20.20'],
          ['Gopal', 30.30, 'gray', '$30.30']
        ]
      end
    end

    describe '#result' do
      it 'returns processed fare information' do
        @comparison.result.should ==  {
          "winner"=>"Opal",
          "alternative"=>"Nopal",
          "savings"=>{
            "week"=>@comparison.savings(1),
            "year"=>@comparison.savings(52)
          },
          "table"=>@comparison.table,
          "stats"=>{}
        }
      end
    end
  end
end
