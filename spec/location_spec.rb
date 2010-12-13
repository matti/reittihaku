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
  

end