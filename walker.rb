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
header = Reittihaku::WALKER::WALKER_FIELD_NAMES.join(";")+"\n"
output_file.write(header)


no_routes = []

route_index = 1

from_locations.each do |from|
to_locations.each do |to|
    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string})")
    
    retries = 0
    begin
      routes = reittiopas.routing(from.location, to.location, routing_options)
    rescue Timeout::Error
      debug("timeout")
      retry
    rescue Reittiopas::AccessError
      raise "invalid credentials"
    rescue
      debug("some network problems occured, lets try again ...")
      if retries < 10
        sleep 5
        retries +=1
        retry
      else
        raise "network was down or unreachable"
      end
    end
    
    if routes.size == 0
      no_routes << [from, to, at] 
      
      failed_fields = eval("[#{Reittihaku::ROUTING::FIELDS_FAILED}]")
      output_file.write(failed_fields.join(";")+"\n")
      next
    end
    
    route = routes.first
    
    coordinate_pairs = []
    walk = route.parts[1]
    walk.sections.each do |point_or_map_location|
      coordinate_pairs << [ point_or_map_location.x, point_or_map_location.y ]
    end

    
    coordinate_pairs.each_cons(2) do |two_pairs|
       line = eval("[#{Reittihaku::WALKER::WALKER_FIELDS}]")
       output_file.write(line.join(";") + "\n")
    end
    
    route_index = route_index + 1
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
