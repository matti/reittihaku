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
