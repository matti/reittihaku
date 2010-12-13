require 'lib/reittihaku'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

address = Reittihaku::Address.parse("1;Ulvilantie;Helsinki")

locations = reittiopas.location(address.to_search_string)


location_selector = Reittihaku::Location::Selector.new(locations)

best_location = location_selector.best_by(address)


line = ""

line_parts = [ address.id, best_location.x, best_location.y,
               address.street, address.number, address.city,
               best_location.name, best_location.number, best_location.city,
               best_location.accuracy, best_location.category,
               best_location.latitude, best_location.longitude]

line_parts.each do |part|
  line << "#{part}" << ";"    
end
 
puts line


