module Reittihaku::ROUTING
  
  # Make searches at following times (HHMM)
  
  AT_TIMES = ["0900", "0920"]

  
  # Pass following options for Reittiopas
  
  OPTIONS = {
    "time" => nil,        # hhmm (overwrites the times specified in AT_TIMES !)
    "timemode" => 1,      # 1: departure, 2: arrival
    "date" => nil,        # yyyymmdd
    "optimize" => nil,    # 1=default, 2=fastest, 3=least transfers, 4=least walking
    "margin" => nil,      # 3 minutes as default. Allowed values  are 0-10
    "penalty" => nil,     # 5 minutes as default. Allowed values 1-99.
    "walkspeed" => nil,   # 1=slow (30 m/min), 2=fast (70 m/min), 3=normal (100 m/min), 4=running (200 m/min), 5=cycling (300 m/min)
    "show" => 5,          # Allowed values 1/3/5
    "use_bus" => nil,     # 1 = use, 0 = do not use
    "use_train" => nil,
    "use_ferry" => nil,
    "use_metro" => nil,
    "use_tram" => nil,
    "mobility" => nil,
    "waitcost" => nil,
    "walkcost" => nil,
  }

end

module Reittihaku
  
  # Use this language for results
  LANG_CODE = "1"   # "1" = finnish, "2" = swedish
    
  # How the location was selected
  ACCURACY = {
    "Osoite ok" => 1,
    "Osoitenumero puuttui, käytettiin pelkkää kadunnimeä" => 2,
    "Käytettiin lähintä osoitenumeroa" => 3,
    "Käytettiin samankaltaista kadunnimeä" => 4,
    "Käytettiin samankaltaisinta kadunnimeä (valinta joukosta)" => 5
  }
   
end