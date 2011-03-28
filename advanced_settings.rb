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
    FIELD_NAMES = ["id", "resolved x", "resolved y",
                   "query street", "query street number", "query street city",
                   "resolved name", "resolved street number", "resolved city",
                   "accuracy", "type", "code", "category",
                   "latitude", "longitude"]
                   
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
    FIELD_NAMES = ["from id", "to id", "fromid_toid", "route number", "at",
                   "from x", "from y",
                   "from address street", "from address number", "from address city",
                   "from location name", "from location number", "from location city",
                   "from address accuracy",
                   "to x", "to y",
                   "to address street", "to address number", "to address city",
                   "to address accuracy",
                   "route time",
                   "route distance",
                   "route walks total time",
                   "route walks total distance",
                   "route total lines"]
                   
    FIELDS = 'from.address.id, to.address.id, (from.address.id.to_s+"_"+to.address.id.to_s), route_index, at,
              from.x, from.y,
              from.address.street, from.address.number, from.address.city,
              from.name, from.number, from.city,
              from.address.accuracy,
              to.x, to.y,
              to.address.street, to.address.number, to.address.city,
              to.name, to.number, to.city,
              to.address.accuracy,
              route.time,
              route.distance,
              route.walks_total_time,
              route.walks_total_distance, 
              route.lines.size'
   
    # Next columns
    
    SUMMARY_FIELD_NAMES = ["departure datetime",
                           "first walk distance",
                           "first stop name",
                           "first stop code",
                           "last stop name",
                           "last stop code",
                           "last walk distance",
                           "arrival datetime"]
                           
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
 
                   if part.stops.size == 1
                     part_fields << ( part.map_locations.size > 0 ? part.map_locations.last.name : nil )
                     part_fields << "maploc"
                   else
                     part_fields << (part.stops.size > 0 ? part.stops.last.names[Reittihaku::LANG_CODE] : nil )
                     part_fields << (part.stops.size > 0 ? part.stops.last.code : nil )
                     part_fields << part.distance
                   end'
  
    # Columns for each line
    LINE_FIELDS = 'part_fields << part.code
                   part_fields << part.stops.first.departure.date_time.to_s
                   part_fields << part.distance'
  
  end

  module WALKER
    
    WALKER_FIELD_NAMES = ["from id", "to id", "fromid_toid", "route number", "x1", "y1", "x2", "y2"]
    WALKER_FIELDS = 'from.address.id, to.address.id, from.address.id.to_s+"_"+to.address.id.to_s, route_index, two_pairs'
    
  end
  
  # How to parse id, street/name, number and city for location.rb
  ADDRESS_MATCHERS = {
    :id => /^\s*([^;]*)\;/,                 # "id;..."
    :city => /^[^;]*\;[^;]*\;([^;]*)/,      # "...;...;city"
    :street => /^[^;]*\;([^;|\d]*)/,        # "...;street;..."
    :number => /^[^;]*\;\D*(\d+)/,          # "...;...8"
    }

end
