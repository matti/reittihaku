require 'rubygems'
require 'lib/reittihaku'



reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

from_location_lines_filename = ARGV[0]
to_location_lines_filename = ARGV[1]
output_filename = ARGV[2]

raise "USAGE: ruby routing.rb from_locations.txt to_locations.txt output.txt" unless from_location_lines_filename && to_location_lines_filename && output_filename


from_location_lines = File.read(from_location_lines_filename)
to_location_lines = File.read(to_location_lines_filename)

from_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(from_location_lines)
to_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(to_location_lines)

from_locations = from_location_lines.map { |from| Reittihaku::Location::Builder.build(from) }
to_locations = to_location_lines.map { |to| Reittihaku::Location::Builder.build(to) }

at_times = Reittihaku::ROUTING::AT_TIMES
routing_options = Reittihaku::ROUTING::OPTIONS.delete_if { |k,v| v.nil? }

output_file = File.open(output_filename, "w")

no_routes = []

from_locations.each do |from|
to_locations.each do |to|
at_times.each do |at|

    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string}) at #{at}")
    
    routes = reittiopas.routing(from.location, to.location, routing_options)    
    
    if routes.size == 0
      no_routes << [from, to, at] 
      
      failed_fields = eval("[#{Reittihaku::ROUTING::FIELDS_FAILED}]")
      output_file.write(failed_fields.join(";")+"\n")
      next
    end
    
    routes.each_with_index do |route, route_index|
      route_index = route_index + 1
      
      line = ""
    
    
      fields = eval "[#{Reittihaku::ROUTING::FIELDS}]"    
      summary_fields = eval "[#{Reittihaku::ROUTING::SUMMARY_FIELDS}]"
                   
                   
      part_fields = []

      route.parts.each_with_index do |part,i|
        # First walk is never included as part
        next if part.is_a?(Reittiopas::Routing::Walk) && i == 0 || i == route.parts.size-1

        if part.is_a?(Reittiopas::Routing::Walk)
          part_fields << "WALK"
          eval Reittihaku::ROUTING::WALK_FIELDS
        end

        if part.is_a?(Reittiopas::Routing::Line)
          part_fields << "LINE"
          eval Reittihaku::ROUTING::LINE_FIELDS
        end

      end

      all_fields = (fields + summary_fields + part_fields)

      output_file.write(all_fields.join(";") + "\n")
    end
    
end
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

puts "\n\n"
puts "-"*80
puts "DONE"
