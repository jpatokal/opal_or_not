require 'spec_helper'
 
describe MyMulti do
  it "returns nil unless there is more than one segment" do
    my_multi = MyMultiWeekly.new([
      {:mode => "bus", :zone => 1, :count => 1},
    ])
    my_multi.compute.should be_nil
  end

  it "selects the highest fare" do
    my_multi = MyMultiWeekly.new([
      {:mode => "bus", :zone => 1, :count => 1},
      {:mode => "train", :zone => 5, :count => 1}
    ])
    my_multi.compute.should == my_multi.fare_table["train"][5]
  end

  it "chooses zone according to distance to CBD when available, not train zone" do
    my_multi = MyMultiWeekly.new([
      {:mode => "bus", :zone => 1, :count => 1},
      {:mode => "train", :zone => 5, :count => 1, :cbd_distance => 5.5}
    ])
    my_multi.compute.should == my_multi.fare_table["train"][1]
  end

  it "converts monthly to weekly correctly" do
    MyMultiMonthly.new.fare_table["train"][1].should == 43.75
  end

  it "converts quarterly to weekly correctly" do
    MyMultiQuarterly.new.fare_table["train"][1].should be_within(0.01).of(37.64)
  end
end
