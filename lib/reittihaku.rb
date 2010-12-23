module Reittihaku
  
  USER=File.read("username")
  PASS=File.read("password")
  
  ENDPOINT = "http://api.reittiopas.fi/public-ytv/fi/api/?user=#{USER}&pass=#{PASS}"
   
  ADDRESS_MATCHERS = {
    :id => /^\s*([^;]*)\;/,
    :city => /^[^;]*\;[^;]*\;([^;]*)/,
    :number => /^[^;]*\;\D*(\d+)/,
    :street => /^[^;]*\;([^;|\d]*)/,
    }

  LANG_CODE = "1"

  ACCURACY = {
    "Osoite ok" => 1,
    "Osoitenumero puuttui, käytettiin pelkkää kadunnimeä" => 2,
    "Käytettiin lähintä osoitenumeroa" => 3,
    "Käytettiin samankaltaista kadunnimeä" => 4,
    "Käytettiin samankaltaisinta kadunnimeä (valinta joukosta)" => 5
  }
  
  
  module LOCATING
        
    FIELDS = 'address.id, best_location.x, best_location.y,
              address.street, address.number, address.city,
              best_location.name, best_location.number, best_location.city,
              best_location.accuracy, best_location.type, best_location.code, best_location.category,
              best_location.latitude, best_location.longitude'
  end
  
  
  module ROUTING

    AT_TIMES = ["0900", "0920"]

    OPTIONS = {
      "time" => nil,        # hhmm
      "timemode" => 1,    # 1: departure, 2: arrival
      "date" => nil,        # yyyymmdd
      "optimize" => nil,    # 1=default, 2=fastest, 3=least transfers, 4=least walking
      "margin" => nil,      # 3 minutes as default. Allowed values  are 0-10
      "penalty" => nil,     # 5 minutes as default. Allowed values 1-99.
      "walkspeed" => nil,   # 1=slow (30 m/min), 2=fast (70 m/min), 3=normal (100 m/min), 4=running (200 m/min), 5=cycling (300 m/min)
      "show" => 5,          # Allowed values 1/3/5
      "use_bus" => nil,     # 1 = use, 0 = do not use
      "use_train" => nil,
      "use_ferry" => nil,
      "use_metro" => nil,
      "use_tram" => nil,
      "mobility" => nil,
      "waitcost" => nil,
      "walkcost" => nil,
    }
    
           
    FIELDS = 'from.address.id, to.address.id, route_index, at,
              from.x, from.y,
              from.address.street, from.address.number, from.address.city,
              from.name, from.number, from.city,
              from.accuracy,
              to.x, to.y,
              to.name, to.number, to.city,
              to.accuracy,
              route.time,
              route.walks_total_time,
              route.walks_total_distance, 
              route.lines.size'
 
    FIELDS_FAILED = 'from.address.id, to.address.id, "NO ROUTE"'
               
    SUMMARY_FIELDS = 'route.parts.first.arrival.date_time.to_s,
                      route.walks.first.distance,
                      (route.lines.size > 0 ? route.lines.first.stops.first.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.first.stops.first.code : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.code : nil),
                      route.walks.last.distance,
                      route.parts.last.arrival.date_time.to_s'
                       
    WALK_FIELDS = 'part_fields << (part.stops.size > 0 ? part.stops.first.names[Reittihaku::LANG_CODE] : nil )
                   part_fields << (part.stops.size > 0 ? part.stops.first.code : nil )
 
                   part_fields << (part.stops.size > 0 ? part.stops.last.names[Reittihaku::LANG_CODE] : nil )
                   part_fields << (part.stops.size > 0 ? part.stops.last.code : nil )
                   part_fields << part.distance'
  
    LINE_FIELDS = 'part_fields << part.code
                   part_fields << part.stops.first.arrival.date_time.to_s
                   part_fields << part.distance'
  end
end


require 'iconv'
require 'vendor/reittiopas/lib/reittiopas'


$: << File.expand_path(File.dirname(__FILE__))

require 'reittihaku/address'
require 'reittihaku/location'
require 'reittihaku/utils'
require 'reittihaku/monkey_patching'
