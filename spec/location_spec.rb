require 'reittihaku'

describe Reittihaku::Location do
  
  describe "creation" do

    it "should encapsulate reittiopas location" do
      reittiopas_location = mock(Reittiopas::Location)
      location = Reittihaku::Location.new(reittiopas_location)

      location.location.should == reittiopas_location
    end
    
    it "should have accuracy" do
      reittiopas_location = mock(Reittiopas::Location)
      location = Reittihaku::Location.new(reittiopas_location)
      
      location.accuracy.should be_nil
    end

    it "should downcase fields" do
      reittiopas_location = mock(Reittiopas::Location)
      reittiopas_location.stub!(:name).and_return("NAME")
      reittiopas_location.stub!(:city).and_return("CITY")
      
      location = Reittihaku::Location.new(reittiopas_location)
      
      location.name.should == "name"
      location.city.should == "city"
    end

    it "should have fields" do
      reittiopas_wgs = mock(Reittiopas::Location::Coordinates::WGS)
      reittiopas_wgs.stub!(:latitude).and_return(60.1234)
      reittiopas_wgs.stub!(:longitude).and_return(24.1234)
            
      reittiopas_kkj = mock(Reittiopas::Location::Coordinates::KKJ)
      reittiopas_kkj.stub!(:x).and_return(123456)
      reittiopas_kkj.stub!(:y).and_return(789)
            
      reittiopas_coordinates = mock(Reittiopas::Location::Coordinates)
      reittiopas_coordinates.stub!(:[]).with(:kkj).and_return(reittiopas_kkj)
      reittiopas_coordinates.stub!(:[]).with(:wgs).and_return(reittiopas_wgs)
      
      reittiopas_location = mock(Reittiopas::Location)
      reittiopas_location.stub!(:coordinates).and_return(reittiopas_coordinates)
      
      reittiopas_location.stub!(:name).and_return("name")
      reittiopas_location.stub!(:city).and_return("city")
      reittiopas_location.stub!(:number).and_return(8)
    
      
      location = Reittihaku::Location.new(reittiopas_location)
      
      location.name.should == "name"
      location.city.should == "city"      
      location.number.should == 8
      location.x.should == 123456
      location.y.should == 789
      location.latitude.should == 60.1234
      location.longitude.should == 24.1234

      location.category.should == "location"
    end
    
    it "should have category" do
      klasses = [ Reittiopas::Location::Street,
                  Reittiopas::Location::Stop,
                  Reittiopas::Location::PointOfInterest,
                  Reittiopas::Location]
                  
      types = ["street", "stop", "poi", "location"]
      
      klasses.each_with_index do |klass, i|
        reittiopas_location = mock(klass)
        reittiopas_location.stub!(:class).and_return(klass.to_s)
        
        location = Reittihaku::Location.new(reittiopas_location)
        location.category.should == types[i]
      end

    end
  end
  


  describe Reittihaku::Location::Selector do
    
    it "should return best" do
      locations = Marshal.load(File.read("spec/assets/locations_olympia.marshal"))
      address = Reittihaku::Address.parse("1;Olympia")
      selector = Reittihaku::Location::Selector.new(locations, address)

      
      @selector.best_by(address).location.should == locations.first
    end

  end
  
  
  
  describe Reittihaku::Location::Builder do
    
    before(:all) do
      @location = Reittihaku::Location::Builder.build("2;2548199;6677769;ulvilantie;19;helsinki;ulvilantie;19;helsinki;1;900;;street;60.20861;24.86607;")
    end
    
    specify { @location.x.should == 2548199 }
    specify { @location.y.should == 6677769 }
    specify { @location.name.should == "ulvilantie" }
    specify { @location.city.should == "helsinki" }
    specify { @location.category.should == "street" }
    specify { @location.code.should be_nil }
    specify { @location.number.should == 19 }
    specify { @location.latitude.should == 60.20861 }
    specify { @location.longitude.should == 24.86607 }
    
  end
end