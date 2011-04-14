require 'rubygems'
require 'lib/reittihaku'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

from_location_lines_filename = ARGV[0]
to_location_lines_filename = ARGV[1]
output_filename = ARGV[2]

raise "USAGE: ruby routing.rb from_locations.txt to_locations.txt output.txt" unless from_location_lines_filename && to_location_lines_filename && output_filename &&
                                                                                     File.exists?(from_location_lines_filename) && File.exists?(to_location_lines_filename)


from_location_lines = File.read(from_location_lines_filename)
to_location_lines = File.read(to_location_lines_filename)

from_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(from_location_lines)
to_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(to_location_lines)

from_location_lines = from_location_lines.split("\n")
to_location_lines = to_location_lines.split("\n")

# Remove header lines
from_location_lines.shift
to_location_lines.shift

from_locations = from_location_lines.map { |from| Reittihaku::Location::Builder.build(from) }
to_locations = to_location_lines.map { |to| Reittihaku::Location::Builder.build(to) }

at_times = Reittihaku::ROUTING::AT_TIMES
routing_options = Reittihaku::ROUTING::OPTIONS.delete_if { |k,v| v.nil? }

output_file = File.open(output_filename, "w")
header = ( Reittihaku::ROUTING::FIELD_NAMES + Reittihaku::ROUTING::SUMMARY_FIELD_NAMES + Reittihaku::ROUTING::DUMMY_TITLES).join(";") + "\n"
output_file.write(header)


no_routes = []

to_locations.each do |to|
from_locations.each do |from|
at_times.each do |at|

    routing_options.merge!({"time" => at})
    
    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string}) at #{at}")
    
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
    
    routes.each_with_index do |route, route_index|
      route_index = route_index + 1
      
      line = ""

      arrival_datetime = route.parts.last.arrival.date_time
      arrival_date = arrival_datetime.strftime "%Y%m%d"
      arrival_time = arrival_datetime.strftime("%H").to_i*3600+arrival_datetime.strftime("%M").to_i*60+arrival_datetime.strftime("%S").to_i

      at_time = (at[0..1].to_i*3600+at[2..3].to_i*60)
      at_time -= 24*3600 if routing_options.key? "date" and arrival_date != routing_options["date"] or Time.now.strftime("%Y%m%d") != arrival_date

      total_route_time = (
        arrival_time - at_time
      ).to_f/60
    
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

puts "\n\nTotal: #{no_routes.size}"
puts "\n\n"
puts "-"*80
puts "DONE"
