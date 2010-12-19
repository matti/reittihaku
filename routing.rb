require 'lib/reittihaku'

# TODO: pois
require 'lib/reittiopas/lib/reittiopas'

class Reittiopas::Routing::Route
  
  def walks_total_time
    time = 0.0
    times = walks.map(&:time)
    times.each { |t| time += t.to_f }
    
    return time
  end
  
  def walks_total_distance
    distance = 0.0
    distances = walks.map(&:distance)
    distances.each { |d| distance += d.to_f}
    
    return distance
  end
  
end


class DateTime
  def to_s
    strftime('%Y-%m-%d %H:%M:%S')
  end
end


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

output_file = File.open(output_filename, "w")

no_routes = []

ats = ["0900"]
from_locations.each do |from|
to_locations.each do |to|
ats.each do |at|

    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string}) at #{at}")
    
    routes = reittiopas.routing(from.location, to.location, {})    
    
    if routes.size == 0
      no_routes << [from, to, at] 
      
      next
    end
    
    route = routes.first
    
    line = ""
    
    
    fields = [ from.address.id, to.address.id,
               from.x, from.y,
               from.address.street, from.address.number, from.address.city,
               from.name, from.number, from.city,
               from.accuracy,
               to.x,to.y,
               to.name, to.number, to.city,
               to.accuracy,
               route.time,
               route.walks_total_time,
               route.walks_total_distance, 
               route.lines.size ]
    
    summary_fields = [route.parts.first.arrival.date_time.to_s,
                      route.walks.first.distance,
                      (route.lines.size > 0 ? route.lines.first.stops.first.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.first.stops.first.code : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.names[Reittihaku::LANG_CODE] : nil),
                      (route.lines.size > 0 ? route.lines.last.stops.last.code : nil),
                      route.walks.last.distance,
                      route.parts.last.arrival.date_time.to_s]
                   
                   
     part_fields = []

     route.parts.each_with_index do |part,i|
       # First walk is never included as part
       next if part.is_a?(Reittiopas::Routing::Walk) && i == 0 || i == route.parts.size-1

       if part.is_a?(Reittiopas::Routing::Walk)
         part_fields << "WALK"
         part_fields << (part.stops.size > 0 ? part.stops.first.names[Reittihaku::LANG_CODE] : nil )
         part_fields << (part.stops.size > 0 ? part.stops.first.code : nil )
         
         part_fields << (part.stops.size > 0 ? part.stops.last.names[Reittihaku::LANG_CODE] : nil )
         part_fields << (part.stops.size > 0 ? part.stops.last.code : nil )
         part_fields << part.distance
       end

       if part.is_a?(Reittiopas::Routing::Line)
         part_fields << "LINE"
         part_fields << part.code
         part_fields << part.stops.first.arrival.date_time.to_s
         part_fields << part.distance
       end

     end

     all_fields = (fields + summary_fields + part_fields)

     output_file.write(all_fields.join(";"))
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
