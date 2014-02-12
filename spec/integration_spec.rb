require 'spec_helper'
 
describe "integration" do
  def compare(data, expected_output)
    @options.compute(data).all.should == expected_output
  end

  before :each do
    @options = FareOptions.new
  end

  describe "fares" do
    it "handles ferry-ferry combos correctly" do
      compare(
        [{ :mode => :ferry, :zone => 1, :count => 10 }, { :mode => :ferry, :zone => 1, :count => 10 }],
        {"Opal"=>44.8, "MyMulti"=>52, "TravelTen"=>96}
      )
    end

    it "handles bus-bus combos correctly" do
      data = [{ :mode => :bus,   :zone => 3, :count => 10 }, { :mode => :bus,   :zone => 3, :count => 10 }]
      options = FareOptions.new.compute(data)
      options.all.should == {"Opal"=>36, "MyMulti"=>44, "TravelTen"=>73.6}
    end

    it "handles train-bus combos correctly" do
      data = [{ :mode => :train, :zone => 3, :count => 10 }, { :mode => :bus,   :zone => 3, :count => 10 }]
      options = FareOptions.new.compute(data)
      options.all.should == {"Opal"=>73.6, "MyMulti"=>52}
    end
  end
end

samples = [
  [{ :mode => :ferry, :zone => 1, :count => 8 }],
  [{ :mode => :ferry, :zone => 1, :count => 9 }],
  [{ :mode => :ferry, :zone => 1, :count => 10 }],
  [{ :mode => :bus,   :zone => 3, :count => 9 }],
  [{ :mode => :bus,   :zone => 3, :count => 10 }],
  [{ :mode => :train, :zone => 5, :count => 9 }],
  [{ :mode => :train, :zone => 5, :count => 10 }],
]

#samples.each do |data|
#  puts data
#  options = FareOptions.new(data)
#  puts options.all
#  puts "Cheapest: #{options.cheapest}"
#  puts "Savings over Opal: $%.02f" % options.savings
#end