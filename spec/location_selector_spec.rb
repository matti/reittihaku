require 'reittihaku'

describe Reittihaku::Location::Selector do
  
  before(:all) do
    @locations = Marshal.load(File.read("spec/assets/locations_olympia.marshal"))
    
    
    @selector = Reittihaku::Location::Selector.new(@locations)
  end
  
  it "should return best" do
    address = Reittihaku::Address.parse("1;Olympia")

    @selector.best_by(address).location.should == @locations.first
  end
end