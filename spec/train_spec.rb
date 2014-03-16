require 'spec_helper'
 
describe Train do
  it "returns nil unless there is a train segment" do
    train = TrainWeekly.new([
      {:mode => "bus", :zone => 1, :count => 1},
    ])
    train.compute.should be_nil
  end

  it "sums up singles by count" do
    train = TrainSingle.new([
      {:mode => "train", :zone => 3, :count => 6},
    ])
    train.compute.should be_within(0.01).of(train.fare_table["train"][3] * 6)
  end

  it "returns off-peak fares only when applicable" do
    time_combos = [
      [{:am => 'before', :pm => 'before'}, nil],
      [{:am => 'before', :pm => 'peak'},   nil],
      [{:am => 'before', :pm => 'after'},  nil],
      [{:am => 'peak',   :pm => 'before'}, nil],
      [{:am => 'peak',   :pm => 'peak'},   nil],
      [{:am => 'peak',   :pm => 'after'},  nil],
      [{:am => 'after',  :pm => 'before'}, 21.0],
      [{:am => 'after',  :pm => 'peak'},   21.0],
      [{:am => 'after',  :pm => 'after'},  21.0]
    ]
    time_combos.each do |combo|
      time, expected = combo
      train = TrainOffPeakReturn.new([
       {:mode => "train", :zone => 3, :count => 6, :time => time}
      ])
      train.compute.should == expected
    end
  end

  it "ignores count and looks up weekly fares directly" do
    train = TrainWeekly.new([
      {:mode => "train", :zone => 3, :count => 6},
    ])
    train.compute.should == train.fare_table["train"][3]
  end

  it "converts monthly to weekly correctly" do
    TrainMonthly.new.fare_table["train"][1].should == 25.5
  end

  it "converts quarterly to weekly correctly" do
    TrainQuarterly.new.fare_table["train"][1].should be_within(0.01).of(21.77)
  end

end
