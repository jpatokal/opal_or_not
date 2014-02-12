require 'spec_helper'
 
describe Fare do
  describe "#new" do
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
