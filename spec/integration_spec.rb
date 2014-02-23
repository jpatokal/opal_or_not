require 'spec_helper'
 
describe "integration" do
  def compare(data, expected_output)
    @options.compute(data).all.should == expected_output
  end

  before :each do
    @options = Comparison.new
  end

  describe "fares" do
    it "handles basic train zones correctly" do
      compare(
        [{ :mode => "train", :zone => 1, :count => 10 }],
        {"Opal"=>26.40, "MyTrain Weekly"=>28, "MyTrain Singles" => 38.0, "MyMulti" => 46}
      )
      compare(
        [{ :mode => "train", :zone => 5, :count => 10 }],
        {"Opal"=>60, "MyTrain Weekly"=>61, "MyTrain Singles" => 86.0, "MyMulti" => 63}
      )
    end

    it "handles ferry-ferry combos correctly" do
      compare(
        [{ :mode => "ferry", :zone => 1, :count => 10 }, { :mode => "ferry", :zone => 1, :count => 10 }],
        {"Opal"=>44.8, "MyMulti"=>54, "TravelTen"=>96}
      )
    end

    it "handles bus-bus combos correctly" do
      compare(
        [{ :mode => "bus",   :zone => 3, :count => 10 }, { :mode => "bus",   :zone => 3, :count => 10 }],
        {"Opal"=>36, "MyMulti"=>46, "TravelTen"=>73.6}
      )
    end

    it "handles train-bus combos correctly" do
      compare(
        [{ :mode => "train", :zone => 1, :count => 10 }, { :mode => "bus",   :zone => 2, :count => 10 }],
        {"Opal"=>54.4, "MyMulti"=>46}
      )
    end
  end
end
