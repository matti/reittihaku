require 'rubygems'
require 'lib/reittihaku'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

address_lines_filename = ARGV[0]
resolved_file_filename = ARGV[1]

raise "USAGE: ruby location.rb address_file.txt resolved_file.txt" unless address_lines_filename && resolved_file_filename && 
                                                                          File.exists?(address_lines_filename)

address_lines = File.read(address_lines_filename)
resolved_file = File.new(resolved_file_filename, "w")

# Parse input addresses as Address objects
addresses = address_lines.map { |l| Reittihaku::Address.parse(l) }

locations = []  # To store all resolved locations
unresolved = [] # To store all locations that Reittiopas could not resolve

addresses.each do |address|
  
  debug("resolving: #{address.id} #{address.to_search_string}")

  all_locations = reittiopas.location(address.to_search_string) # Everything what Reittiopas finds with our search
  Reittihaku::Location::Sanitizer.to_latin1(all_locations)      # Convert names to latin-1
  
  location_selector = Reittihaku::Location::Selector.new(all_locations, address)
  
  best_location = location_selector.best_location  # Select one out of all possible results, but can also select none if x&y coordinates are missing

    
  if best_location
    locations << best_location
      
    # Build the result line 
    line = ""
    line_parts = eval "[#{Reittihaku::LOCATING::FIELDS}]"

    # And join each part with ";"
    line_parts.each { |part| line << "#{part}" << ";" }    

    resolved_file.write(line + "\n")
        
  else
    unresolved << address   # If no location was resolved
  end

end

resolved_file.close


# Write statistics to stdout

puts "\n\nUnresolved"
puts "-"*80
unresolved.each do |address|
    puts "#{address.id};#{address.street};#{address.number};#{address.city}"
end
puts "\nTotal: #{unresolved.size}"
puts "\n"

puts "\nResolved"
puts "-"*80

puts "\nTotal: #{locations.size}"
puts ""
puts "Wrote to #{resolved_file.path}"
puts ""

