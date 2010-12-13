module Reittihaku

  class Address
      
    attr_reader :id, :street, :number, :city
  
    def initialize(opts)
      @id = opts[:id]
      @street = sanitize(opts[:street])
      @number = opts[:number].to_i if opts[:number]
      @city = sanitize(opts[:city])
    end
  
    def self.parse(string)
      parser = Parser.new(string)
      parsed_opts = parser.parse

      new(parsed_opts)
    end
    
    def sanitize(string)
      string.strip.downcase if string
    end

    def to_search_string
      string = "#{@street} #{@number}"
      string << ", #{@city}" if @city

      string
    end
  end
  
  
  class Address::Parser

    def initialize(string)
      @string = string
    end
    
    def parse
      id = match(Reittihaku::ADDRESS_MATCHERS[:id])
      city = match(Reittihaku::ADDRESS_MATCHERS[:city])
      number = match(Reittihaku::ADDRESS_MATCHERS[:number])
      street = match(Reittihaku::ADDRESS_MATCHERS[:street])
      
      return {:id => id,
              :city => city,
              :number => number,
              :street => street}
    end
    
    def match(regexp)
      match = @string.match(regexp)
      
      match ? match[1] : nil
    end 

  end    
  
  

end

