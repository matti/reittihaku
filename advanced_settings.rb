module Reittihaku
  
  begin
    USER=File.read("username")    # Reittiopas username
  rescue
    puts "Could not read file 'username'"
    exit 1
  end
  
  begin
    PASS=File.read("password")    # Reittiopas password
  rescue
    puts "Could not read file 'password'"
    exit 1
  end
    

  # FIELDS FOR OUTPUTS
   
  # Fields for location.rb
  module LOCATING
    
    # location.rb resulting location lines
        
    FIELDS = 'address.id, best_location.x, best_location.y,
              address.street, address.number, address.city,
              best_location.name, best_location.number, best_location.city,
              best_location.accuracy, best_location.type, best_location.code, best_location.category,
              best_location.latitude, best_location.longitude'
  end
  
  
  # Fields for routing.rb
  module ROUTING

    # Columns if no route was found
    FIELDS_FAILED = 'from.address.id, to.address.id, "NO ROUTE"'
    
    # The first columns
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
   
    # Next columns
    SUMMARY_FIELDS = 'route.parts.first.departure.date_time.to_s,
                      route.walks.first.distance,
                      (route.lines.size > 0 ? route.lines.first.stops.first.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.first.stops.first.code : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.code : nil),
                      route.walks.last.distance,
                      route.parts.last.arrival.date_time.to_s'
    
    # Columns for each walk
    WALK_FIELDS = 'part_fields << (part.stops.size > 0 ? part.stops.first.names[Reittihaku::LANG_CODE] : nil )
                   part_fields << (part.stops.size > 0 ? part.stops.first.code : nil )
 
                   part_fields << (part.stops.size > 0 ? part.stops.last.names[Reittihaku::LANG_CODE] : nil )
                   part_fields << (part.stops.size > 0 ? part.stops.last.code : nil )
                   part_fields << part.distance'
  
    # Columns for each line
    LINE_FIELDS = 'part_fields << part.code
                   part_fields << part.stops.first.departure.date_time.to_s
                   part_fields << part.distance'
  
  end

  
  # How to parse id, street/name, number and city for location.rb
  ADDRESS_MATCHERS = {
    :id => /^\s*([^;]*)\;/,                 # "id;..."
    :city => /^[^;]*\;[^;]*\;([^;]*)/,      # "...;...;city"
    :street => /^[^;]*\;([^;|\d]*)/,        # "...;street;..."
    :number => /^[^;]*\;\D*(\d+)/,          # "...;...8"
    }

end