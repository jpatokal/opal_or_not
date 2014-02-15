require 'spec_helper'
 
describe Fare do
  describe "#new" do
    it "turns string keys into symbols" do
      data = [{"mode" => "a", "zombie" => "b"}]
      fare = Fare.new(data)
      fare.data.should == [{:mode => "a", :zombie => "b"}]
    end

    it "converts count, zone into numbers" do
      data = [{:mode => "z", :count => "69", :zone => "42"}]
      fare = Fare.new(data)
      fare.data.should == [{:mode => "z", :count => 69, :zone => 42}]
    end

    it "sorts data by mode of travel" do
      data = [{:mode => :z}, {:mode => :a}, {:mode => :a}]
      fare = Fare.new(data)
      fare.data.should == [{:mode => :a}, {:mode => :a}, {:mode => :z}]
    end
  end

  describe "#compute" do
    it "sums up fares" do
      fare = Fare.new
      stub(fare).compute_journey { [1, 2, 3] }
      fare.compute.should == 6
    end

    it "returns nil if there's a single nil segment" do
      fare = Fare.new
      stub(fare).compute_journey { [1, nil, 3] }
      fare.compute.should == nil
    end
  end
end
