require 'reittihaku'

describe Reittihaku::Address do
  
  describe "attributes" do
    subject { Reittihaku::Address.parse("1;a") }
    it { should respond_to(:accuracy) }
  end
  
  describe "from line" do

    before(:all) do
      address_full = Reittihaku::Address.parse("100;Ulvil an-tie 19 a 10;Helsinki")
      address_street = Reittihaku::Address.parse("100;Ulvil an-tie")
      address_street_city = Reittihaku::Address.parse("100;Ulvil an-tie ; helsinki")
      address_street_and_number = Reittihaku::Address.parse("100;Ulvil an-tie 19")
    
      @addresses = [address_full, address_street, address_street_city, address_street_and_number]
      @with_number = [address_full, address_street_and_number]
      @with_city = [address_full, address_street_city]
    end

    it "should parse id" do
      @addresses.each { |a| a.id.should == "100" }
    end

    it "should parse street" do
      @addresses.each { |a| a.street.should == "ulvil an-tie" }
    end

    it "should parse number" do
      @with_number.each { |a| a.number.should == 19 }
    end

    it "should parse city" do
      @with_city.each { |a| a.city.should == "helsinki" }
    end
  
  end

  describe "to query address" do
    
    before(:all) do
      
    end
    
    it "should return a search address with city" do
      address = Reittihaku::Address.parse("abc;Ulvil an-tie 19 a 10;Helsinki")
      address.to_search_string.should == "ulvil an-tie 19, helsinki"
    end

    it "should return a serach address without city" do
      address = Reittihaku::Address.parse("abc;Ulvil an-tie 19 a 10")
      address.to_search_string.should == "ulvil an-tie 19"
    end
    
  end
end