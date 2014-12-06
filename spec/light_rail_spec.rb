require 'spec_helper'
 
describe LightRail do
  it "returns nil unless there is a light-rail segment" do
    light_rail =  LightRailWeekly.new([
      {:mode => "bus", :zone => 1, :count => 1},
    ])
    light_rail.compute.should be_nil
  end

  describe LightRailSingle do
    it "sums up singles by count" do
      light_rail =  LightRailSingle.new([
        {:mode => "light-rail", :zone => 2, :count => 6},
      ])
      light_rail.compute.should be_within(0.01).of(light_rail.fare_table["light-rail"][2] * 6)
    end

    it "does not offer singles for 4 or more days per week" do
      LightRailSingle.new([{:mode => "light-rail", :zone => 2, :count => 8}]).compute.should be_nil
    end
   end

  describe LightRailReturn do
    it "sums up singles by half count" do
      light_rail =  LightRailReturn.new([
        {:mode => "light-rail", :zone => 2, :count => 6},
      ])
      light_rail.compute.should be_within(0.01).of(light_rail.fare_table["light-rail"][2] * 3)
    end
  end

  describe LightRailWeekly do
    it "ignores count and looks up weekly fares directly" do
      light_rail =  LightRailWeekly.new([
        {:mode => "light-rail", :zone => 2, :count => 6},
      ])
      light_rail.compute.should == light_rail.fare_table["light-rail"][2]
    end

    it "does not offer weeklies for 2 or less days per week" do
      LightRailWeekly.new([{:mode => "light-rail", :zone => 2, :count => 4}]).compute.should be_nil
    end
  end
end
