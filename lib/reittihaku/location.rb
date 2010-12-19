module Reittihaku
  
  class Location
    
    attr_reader :location, :address
    attr_accessor :accuracy
    
    def initialize(reittiopas_location, address)
      @location = reittiopas_location
      @address = address
    end

    def name
      @location.name.downcase if @location.name
    end
    
    def city
      @location.city.downcase if @location.city
    end
    
    def number
      @location.number
    end
    
    def x
      @location.coordinates[:kkj].x
    end
    
    def y
      @location.coordinates[:kkj].y
    end
    
    def latitude
      @location.coordinates[:wgs].latitude
    end
    
    def longitude
      @location.coordinates[:wgs].longitude
    end
    
    def category
      case @location.class.to_s
        when "Reittiopas::Location::Street" then "street"
        when "Reittiopas::Location::Stop"   then "stop"
        when "Reittiopas::Location::PointOfInterest"  then "poi"
        else "location"
      end
    end
    
    def type
      @location.respond_to?(:type) ? @location.type : nil
    end
    
    def code
      @location.respond_to?(:code) ? @location.code : nil
    end
  end
  
  class Location::Builder
    
    def self.build(string)
      
      parts = string.split(';')

      fields = :id, :x, :y,
               :query_street, :query_number, :query_city,
               :name1, :number, :city,
               :accuracy, :type, :code, :category,
               :lat, :lon

      attributes = {}
      fields.each_with_index { |a,i| attributes[a] = parts[i] if parts[i] != "" }
      
      xml_attributes = attributes.clone
      extra_fields = :id, :query_street, :query_number, :query_city, :accuracy 
      xml_attributes.each_key { |key| xml_attributes.delete(key) if extra_fields.include? key }

      builder = Nokogiri::XML::Builder.new do |xml|
          xml.LOC(xml_attributes)
      end
      
      Location.new(Reittiopas::Location.parse(Nokogiri::XML(builder.to_xml).elements.first),
                   Address.new(:id => attributes[:id],
                               :street => attributes[:query_street],
                               :number => attributes[:query_number],
                               :city => attributes[:city]) )
    end
  end
  
  module Location::Sanitizer

    def self.utf8_to_latin1(string)
      i = Iconv.new("LATIN1//TRANSLIT//IGNORE", "UTF8")
      return i.iconv(string)
    end

    def self.latin1_to_utf8(string)
      i = Iconv.new("UTF8", "LATIN1//TRANSLIT//IGNORE")
      return i.iconv(string)
    end
    
    def self.to_latin1(locations)
        
        # substitutions = { "Ä" => "ä",
        #                          "Ö" => "ö",
        #                          "Å" => "å"}
        #                          
        Array(locations).each do |location|
          location.name = utf8_to_latin1(location.name)
          #substitutions.each { |k,v| location.name = location.name.gsub(k,v) }
        end
        
    end
    
  end
  
  class Location::Selector
    
    
    def initialize(reittiopas_locations, address)
      @address = address
      @locations = reittiopas_locations.map { |l| Location.new(l, @address.id ) }
    end
    
    def best_location
      
      best = nil

      if @locations.size == 1
        best = resolve_single(@locations.first)
      elsif @locations.size > 1
        best = resolve_multiple(@locations)
      end
      
      
      best = nil if best && ( best.x.nil? || best.y.nil? )
      
      return best
    end


    private

    def resolve_single(l)

      if @address.street == l.name && @address.number == l.number
        l.accuracy = ACCURACY["Osoite ok"]
      elsif @address.street == l.name && ( @address.number.nil? || @address.number == "" )
        l.accuracy = ACCURACY["Osoitenumero puuttui, käytettiin pelkkää kadunnimeä"] 
      else  
        l.accuracy = ACCURACY["Käytettiin samankaltaista kadunnimeä"]
      end

      return l
    end

    def resolve_multiple(locations)

      winner = [-1,locations.first]

      name_to_match = @address.street

      locations.each do |l|
        score = 0

        next unless l.name.include? name_to_match
        name_to_match.split("").each do |c|
          score = score + l.name.count(c)
        end

        if score > winner[0]
          winner = [score, l]
        end

      end

      l = winner[1]
      l.accuracy = ACCURACY["Käytettiin samankaltaisinta kadunnimeä (valinta joukosta)"]

      return l    
    end
    
    
    
  end
  
  
end