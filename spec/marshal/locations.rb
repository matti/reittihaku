require 'lib/reittihaku'

r = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

adr = Reittihaku::Address.parse("1;Olympia")
locations = r.location(adr.to_search_string)

f = File.open("spec/assets/locations_olympia.marshal", "w")
f.write Marshal.dump(locations)
f.close