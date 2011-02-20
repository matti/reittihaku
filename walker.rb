require 'rubygems'
require 'lib/reittihaku'
require 'walker_settings'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

from_location_lines_filename = ARGV[0]
to_location_lines_filename = ARGV[1]
output_filename = ARGV[2]

raise "USAGE: ruby walker.rb from_locations.txt to_locations.txt output.txt" unless from_location_lines_filename && to_location_lines_filename && output_filename &&
                                                                                     File.exists?(from_location_lines_filename) && File.exists?(to_location_lines_filename)


from_location_lines = File.read(from_location_lines_filename)
to_location_lines = File.read(to_location_lines_filename)

from_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(from_location_lines)
to_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(to_location_lines)

from_locations = from_location_lines.map { |from| Reittihaku::Location::Builder.build(from) }
to_locations = to_location_lines.map { |to| Reittihaku::Location::Builder.build(to) }

routing_options = Reittihaku::WALKER::OPTIONS.delete_if { |k,v| v.nil? }


output_file = File.open(output_filename, "w")

no_routes = []

from_locations.each do |from|
to_locations.each do |to|
    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string})")
    
    routes = reittiopas.routing(from.location, to.location, routing_options)
    
    if routes.size == 0
      no_routes << [from, to, at] 
      
      failed_fields = eval("[#{Reittihaku::ROUTING::FIELDS_FAILED}]")
      output_file.write(failed_fields.join(";")+"\n")
      next
    end
    
    route = routes.first
    
    coordinates = []
    walk = route.parts[1]
    walk.sections.each do |point_or_map_location|
      coordinates << point_or_map_location.x
      coordinates << point_or_map_location.y
    end

    fields = eval "[#{Reittihaku::WALKER::FIELDS}]"    
    from_to_and_coordinates = (fields + coordinates)
    output_file.write(from_to_and_coordinates.join(";") + "\n")
    
end
end


output_file.close

puts "\n\n"
puts "No Routes"
puts "-"*80

no_routes.each do |from_to_at|
  from, to, at = from_to_at
  
  puts "from: #{from.address.to_search_string} to: #{to.address.to_search_string} at #{at}"
end

puts "\n\nTotal: #{no_routes.size}"
puts "\n\n"
puts "-"*80
puts "DONE"
