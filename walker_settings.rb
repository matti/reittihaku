module Reittihaku
  
  module WALKER
    
    OPTIONS = {
      "time" => nil,        # hhmm (overwrites the times specified in AT_TIMES !)
      "timemode" => 1,      # 1: departure, 2: arrival
      "date" => nil,        # yyyymmdd
      "optimize" => nil,    # 1=default, 2=fastest, 3=least transfers, 4=least walking
      "margin" => nil,      # 3 minutes as default. Allowed values  are 0-10
      "penalty" => nil,     # 5 minutes as default. Allowed values 1-99.
      "walkspeed" => nil,   # 1=slow (30 m/min), 2=fast (70 m/min), 3=normal (100 m/min), 4=running (200 m/min), 5=cycling (300 m/min)
      "show" => 1,          # Allowed values 1/3/5
      "use_bus" => 0,     # 1 = use, 0 = do not use
      "use_train" => 0,
      "use_ferry" => 0,
      "use_metro" => 0,
      "use_tram" => 0,
      "mobility" => nil,
      "waitcost" => nil,
      "walkcost" => nil,
    }
    
  end
end