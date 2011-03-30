require 'rubygems'
require 'lib/reittihaku'

class << Hash
  def create(keys, values)
    self[*keys.zip(values).flatten]
  end
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
  values = Hash.create Reittihaku::AVERAGE::INPUT_FIELDS.map {|k| k.to_sym}, row.split(';')

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

  avg_route_time = nil
  avg_route_distance = nil
  avg_start_walking_time = nil
  avg_end_walking_time = nil
  avg_route_walks_total_time = nil
  avg_start_walking_distance = nil
  avg_end_walking_distance = nil
  avg_route_walks_total_distance = nil
  avg_swaps = nil
  used_bus = nil
  used_tram = nil
  used_subway = nil
  used_ferry = nil

  results.push result_hash
end

results.each do |row|


  fields = Reittihaku::AVERAGE::FIELDS.map{|v| eval "row[:#{v.to_sym}]"}
  output_file.write(fields.join(';') + "\n")

end


output_file.close
