require 'spec_helper'
 
describe Fare do
  describe "#new" do
    it "sorts data by mode of travel" do
      data = [{:mode => :z}, {:mode => :a}, {:mode => :a}]
      fare = Fare.new(data)
      fare.data.should == [{:mode => :a}, {:mode => :a}, {:mode => :z}]
    end
  end
end
