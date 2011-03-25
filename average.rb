require 'rubygems'
require 'lib/reittihaku'

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

from_location_lines_filename = ARGV[0]
to_location_lines_filename = ARGV[1]
output_filename = ARGV[2]

raise "USAGE: ruby average.rb from_locations.txt to_locations.txt output.txt" unless from_location_lines_filename && to_location_lines_filename && output_filename &&
                                                                                     File.exists?(from_location_lines_filename) && File.exists?(to_location_lines_filename)

from_location_lines = File.read(from_location_lines_filename)
to_location_lines = File.read(to_location_lines_filename)

from_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(from_location_lines)
to_location_lines = Reittihaku::Location::Sanitizer.latin1_to_utf8(to_location_lines)

from_locations = from_location_lines.map { |from| Reittihaku::Location::Builder.build(from) }
to_locations = to_location_lines.map { |to| Reittihaku::Location::Builder.build(to) }

at_times = Reittihaku::AVERAGE::AT_TIMES
average_options = Reittihaku::AVERAGE::OPTIONS.delete_if { |k,v| v.nil? }

output_file = File.open(output_filename, "w")

no_routes = []

from_locations.each do |from|
to_locations.each do |to|
at_times.each do |at|

    average_options.merge!({"time" => at})

    debug("routing #{from.address.id} (#{from.address.to_search_string}) to #{to.address.id} (#{to.address.to_search_string}) at #{at}")

    retries = 0
    begin
      routes = reittiopas.routing(from.location, to.location, average_options)
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

      failed_fields = eval("[#{Reittihaku::AVERAGE::FIELDS_FAILED}]")
      output_file.write(failed_fields.join(";")+"\n")
      next
    end

    routes_found = routes.count

    date = if average_options[:date]
      average_options[:date]
    else
      Date.today
    end
    time = at
    total_walking = 0
    total_changes = 0
    total_vehicle_types = 0

    routes.each_with_index do |route, route_index|
      route_vehicle_types = []
      route_index = route_index + 1

      route.parts.each_with_index do |part,i|
        # First walk is never included as part
        next if part.is_a?(Reittiopas::Routing::Walk) && i == 0 || i == route.parts.size-1

        if part.is_a?(Reittiopas::Routing::Walk)
          total_walking += part.time
        end

        if part.is_a?(Reittiopas::Routing::Line)
          total_changes += 1
          route_vehicle_types << part.line_type unless route_vehicle_types.include? part.line_type
        end

      end

      total_vehicle_types += route_vehicle_types.count

    end

    walking = (total_walking/routes_found)
    changes = ((total_changes-1)/routes_found)
    vehicle_types = (total_vehicle_types/routes_found)

    # from, to, date, time, average walking time, average amount of changes, average amount of different vehicles
    all_fields = [from.address.to_search_string, to.address.to_search_string, date, time, walking, changes, vehicle_types]

    output_file.write(all_fields.join(";") + "\n")

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
