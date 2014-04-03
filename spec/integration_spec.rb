require 'spec_helper'
 
describe "integration" do
  def compare(data, expected_output, unwanted_keys=[])
    result  = Comparison.new(data).compute.all
    expected_output.each do |key,value|
      result.keys.should include(key)
      result[key].should be_within(0.01).of(value)
    end
    result.keys.should_not include(unwanted_keys)
  end

  describe "fares" do
    it "handles basic train zones correctly" do
      compare(
        [{ :mode => "train", :zone => 1, :count => 6 }],
        {"Opal"=>19.80, "MyTrain Weekly"=>28, "MyTrain Singles" => 22.80},
        ["MyMulti Weekly", "MyMulti Monthly", "MyMulti Quarterly"]
      )
      compare(
        [{ :mode => "train", :zone => 5, :count => 10 }],
        {"Opal"=>60, "MyTrain Weekly"=>61},
        ["MyTrain Singles"]
      )
    end

    it "handles off-peak trains correctly" do
      compare(
        [{ :mode => "train", :zone => 1, :count => 4, :time => {:am => 'after', :pm => 'peak'} }],
        {"Opal"=>11.22, "MyTrain Off-Peak Returns"=>10.0, "MyTrain Singles"=>15.2},
        ["MyMulti Weekly", "MyMulti Monthly", "MyMulti Quarterly"]
      )
      compare(
        [{ :mode => "train", :zone => 1, :count => 10, :time => {:am => 'after', :pm => 'after'} }],
        {"Opal"=>18.48, "MyTrain Off-Peak Returns"=>25.0},
        ["MyTrain Singles", "MyMulti Weekly", "MyMulti Monthly", "MyMulti Quarterly"]
      )
      compare(
        [{ :mode => "train", :zone => 1, :count => 10, :time => {:am => 'before', :pm => 'before'} }],
        {"Opal"=>18.48, "MyTrain Weekly"=>28},
        ["MyTrain Off-Peak Returns", "MyMulti Weekly", "MyMulti Monthly", "MyMulti Quarterly"]
      )
    end

    it "handles ferry-ferry combos correctly" do
      compare(
        [{ :mode => "ferry", :zone => 1, :count => 10 }, { :mode => "ferry", :zone => 1, :count => 10 }],
        {"Opal"=>56, "MyMulti Weekly"=>54, "MyMulti Monthly"=>51.5, "MyMulti Quarterly"=>44.1, "TravelTen"=>96}
      )
    end

    it "handles bus-bus combos correctly" do
      compare(
        [{ :mode => "bus",   :zone => 3, :count => 10 }, { :mode => "bus",   :zone => 3, :count => 10 }],
        {"Opal"=>36, "MyMulti Weekly"=>46, "TravelTen"=>73.6}
      )
    end

    it "handles train-bus combos correctly" do
      compare(
        [{ :mode => "train", :zone => 1, :count => 10 },
         { :mode => "bus",   :zone => 2, :count => 10 }],
        {"Opal"=>54.4, "MyMulti Weekly"=>46}
      )
      compare(
        [{ :mode => "train", :zone => 1, :count => 10, :cbd_distance => 23.4 },
         { :mode => "bus",   :zone => 2, :count => 10 }],
        {"Opal"=>54.4, "MyMulti Weekly"=>54}
      )
      compare(
        [{ :mode => "train", :zone => 1, :count => 10, :time => {:am => 'before', :pm => 'after'} },
         { :mode => "bus",   :zone => 2, :count => 10 }],
        {"Opal"=>46.48, "MyMulti Weekly"=>46}
      )
    end
  end
end
