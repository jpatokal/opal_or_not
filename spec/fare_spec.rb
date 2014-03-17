require 'spec_helper'
 
describe Fare do
  describe "#compute" do
    it "sums up fares" do
      fare = Fare.new
      stub(fare).compute_journey { [1, 2, 3] }
      fare.compute.should == 6
    end

    it "rounds segments correctly" do
      fare = Fare.new
      stub(fare).single { 3.80 }
      fare.compute_segment({:count => 6}).should == 22.8
    end

    it "returns nil if there's a single nil segment" do
      fare = Fare.new
      stub(fare).compute_journey { [1, nil, 3] }
      fare.compute.should == nil
    end
  end
end
