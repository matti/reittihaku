require 'rubygems'
require 'lib/reittihaku'

class << Hash
  def create(keys, values)
    self[*keys.zip(values).flatten]
  end
end

def average_arr array
  array.inject {|sum, el| sum + el} / array.size
end

def average field_name, values
  "%.3f" % average_arr(values.map {|r| r[field_name].to_f})
end

reittiopas = Reittiopas.new(:username => Reittihaku::USER, :password => Reittihaku::PASS)

input_filename = ARGV[0]
output_filename = ARGV[1]

raise "USAGE: ruby average.rb input.txt output.txt" unless input_filename && output_filename && File.exists?(input_filename)

input_lines = File.read(input_filename)

input_rows = input_lines.map { |line| line }

input_rows.shift # remove header


output_file = File.open(output_filename, "w")

header = Reittihaku::AVERAGE::FIELD_NAMES.join(";") + "\n"
output_file.write(header)

data = Hash.new

input_rows.each do |row|
  values = Hash.create Reittihaku::AVERAGE::INPUT_FIELDS.map {|k| k.to_sym} + [:rest], row.split(';', Reittihaku::AVERAGE::INPUT_FIELDS.size+1)

  data_id = values[:fromid_toid]

  data[data_id] = Array.new if data[data_id].nil?
  data[data_id].push values
end


results = Array.new

data.each_pair do |k,v|
  result_hash = Hash.new

  # copy static fields
  [:fromid_toid, :from_id, :from_x, :from_y, :from_address_street,
   :from_address_number, :from_address_city, :to_id, :to_x, :to_y,
   :to_address_street, :to_address_number, :to_address_city].each do |key|
    result_hash[key] = v.first[key]
  end


  ats = v.map {|r| r[:at]}
  min_at = ats.min
  max_at = ats.max
  result_hash[:min_at] = "#{min_at[0..1]}:#{min_at[2..3]}"
  result_hash[:max_at] = "#{max_at[0..1]}:#{max_at[2..3]}"

  dates = v.map {|r| DateTime.parse(r[:departure_datetime])}
  result_hash[:min_date] = dates.min.strftime "%Y-%m-%d"
  result_hash[:max_date] = dates.max.strftime "%Y-%m-%d"

  result_hash[:count] = v.length

  result_hash[:avg_route_time] = average :route_time, v
  result_hash[:avg_total_route_time] = average :total_route_times, v
  result_hash[:avg_route_distance] = average :route_distance, v
  result_hash[:avg_start_walking_time] = average :first_walk_time, v
  result_hash[:avg_end_walking_time] = average :last_walk_time, v
  result_hash[:avg_route_walks_total_time] = average :route_walks_total_time, v
  result_hash[:avg_start_walking_distance] = average :first_walk_distance, v
  result_hash[:avg_end_walking_distance] = average :last_walk_distance, v
  result_hash[:avg_route_walks_total_distance] = average :route_walks_total_distance, v

  result_hash[:avg_swaps] = average_arr(v.map {|r| r[:route_lines].to_i-1}).to_i
  result_hash[:used_bus] = false
  result_hash[:used_tram] = false
  result_hash[:used_metro] = false
  result_hash[:used_ferry] = false

  parts = v.map {|r| r[:rest].split(";")}.flatten
  parts.each_with_index do |part, i|
    next unless part == "LINE"
    type_id = parts[i+2].to_i
    if Reittihaku::BUS_TYPES.include? type_id
      result_hash[:used_bus] = true
    elsif Reittihaku::TRAM_TYPES.include? type_id
      result_hash[:used_tram] = true
    elsif Reittihaku::METRO_TYPES.include? type_id
      result_hash[:used_metro] = true
    elsif Reittihaku::FERRY_TYPES.include? type_id
      result_hash[:used_ferry] = true
    end
  end

  results.push result_hash
end

results.each do |row|


  fields = Reittihaku::AVERAGE::FIELDS.map{|v| eval "row[:#{v.to_sym}]"}
  output_file.write(fields.join(';') + "\n")

end


output_file.close
