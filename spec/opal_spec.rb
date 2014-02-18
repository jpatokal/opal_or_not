require 'spec_helper'
 
describe Opal do
  it "counts multiple segments on same mode as one" do
    opal = Opal.new([
      {:mode => "bus", :zone => 1, :count => 1},
      {:mode => "bus", :zone => 1, :count => 1}
    ])
    opal.compute.should == opal.fare_table["bus"][1]
  end

  it "counts segments on different modes separately" do
    opal = Opal.new([
      {:mode => "bus", :zone => 1, :count => 1},
      {:mode => "train", :zone => 1, :count => 1}
    ])
    opal.compute.should == opal.fare_table["bus"][1] + opal.fare_table["train"][1]
  end

  it "applies a daily cap of $15" do
    opal = Opal.new([
      {:mode => "bus", :zone => 3, :count => 2},
      {:mode => "train", :zone => 5, :count => 2}
    ])
    opal.compute.should == 15
  end

  it "only counts up to 8 journeys" do
    opal = Opal.new([
      {:mode => "bus", :zone => 1, :count => 10},
    ])
    opal.compute.should == opal.fare_table["bus"][1] * 8
  end
end
