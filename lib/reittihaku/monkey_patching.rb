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

  def to_date_s
    strftime('%Y-%m-%d')
  end
end

class Hash
  def self.create(keys, values)
    self[*keys.zip(values).flatten]
  end
end

class Array
  def avg
    self.inject {|sum, el| sum + el} / self.size
  end
end
