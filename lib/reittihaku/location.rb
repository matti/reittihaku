module Reittihaku
  
  class Location
    
    attr_reader :location
    attr_accessor :accuracy
    
    def initialize(reittiopas_location)
      @location = reittiopas_location
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
    
  end
  
  
  
  class Location::Selector
    
    
    def initialize(locations)
      @locations = locations.map { |l| Location.new(l) }
    end
    
    def best_by(address)
      
      best = nil

      if @locations.size == 1
        best = resolve_single(@locations.first, address)
      elsif @locations.size > 1
        best = resolve_multiple(@locations, address)
      end
      
      
      best = nil if best && best.x.nil? || best.y.nil?
      
      return best
    end


    private

    def resolve_single(l, address)

      if address.street == l.name && address.number == l.number
        l.accuracy = ACCURACY["Osoite ok"]
      elsif address.street == l.name && ( address.number.nil? || address.number.empty? )
        l.accuracy = ACCURACY["Osoitenumero puuttui, käytettiin pelkkää kadunnimeä"] 
      else  
        l.accuracy = ACCURACY["Käytettiin samankaltaista kadunnimeä"]
      end

      return l
    end

    def resolve_multiple(locations, address)

      winner = [-1,locations.first]

      name_to_match = address.street

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