require 'spec_helper'
 
describe "integration" do
  def compare(data, expected_output)
    @options.compute(data).all.should == expected_output
  end

  before :each do
    @options = Comparison.new
  end

  describe "fares" do
    it "handles ferry-ferry combos correctly" do
      compare(
        [{ :mode => "ferry", :zone => 1, :count => 10 }, { :mode => "ferry", :zone => 1, :count => 10 }],
        {"Opal"=>44.8, "MyMulti"=>54, "TravelTen"=>96}
      )
    end

    it "handles bus-bus combos correctly" do
      data = [{ :mode => "bus",   :zone => 3, :count => 10 }, { :mode => "bus",   :zone => 3, :count => 10 }]
      options = Comparison.new.compute(data)
      options.all.should == {"Opal"=>36, "MyMulti"=>46, "TravelTen"=>73.6}
    end

    it "handles train-bus combos correctly" do
      data = [{ :mode => "train", :zone => 1, :count => 10 }, { :mode => "bus",   :zone => 2, :count => 10 }]
      options = Comparison.new.compute(data)
      options.all.should == {"Opal"=>54.4, "MyMulti"=>46}
    end
  end
end

samples = [
  [{ :mode => "ferry", :zone => 1, :count => 8 }],
  [{ :mode => "ferry", :zone => 1, :count => 9 }],
  [{ :mode => "ferry", :zone => 1, :count => 10 }],
  [{ :mode => "bus",   :zone => 3, :count => 9 }],
  [{ :mode => "bus",   :zone => 3, :count => 10 }],
  [{ :mode => "train", :zone => 5, :count => 9 }],
  [{ :mode => "train", :zone => 5, :count => 10 }],
]

#samples.each do |data|
#  puts data
#  options = Comparison.new(data)
#  puts options.all
#  puts "Cheapest: #{options.cheapest}"
#  puts "Savings over Opal: $%.02f" % options.savings
#end
