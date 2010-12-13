require 'lib/reittihaku'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

address = Reittihaku::Address.parse("1;Ulvilantie 19;Helsinki")


locations = reittiopas.location(address.to_search_string)


location_selector = Reittihaku::Location::Selector.new(locations)

best_location = location_selector.best_by(address)

x = reittiopas.routing(best_location.location, best_location.location, {})

puts x.inspect 