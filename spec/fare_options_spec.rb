require 'spec_helper'
 
describe FareOptions do
  before :each do
    @options = FareOptions.new({'Opal' => 10, 'Nopal' => 20, 'Gopal' => 30})
  end

  describe '#cheapest' do
    it 'returns the cheapest fare' do
      @options.cheapest.should == 'Opal'
    end

    it 'returns the cheapest non-Opal fare' do
      @options.cheapest(false).should == 'Nopal'
    end
  end
end
