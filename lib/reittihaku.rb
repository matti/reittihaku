require 'rubygems'
#TODO: dependency
require 'lib/reittiopas/lib/reittiopas'

require 'iconv'

$: << File.expand_path(File.dirname(__FILE__))


module Reittihaku
  
  USER=File.read("username")
  PASS=File.read("password")
  
  ENDPOINT = "http://api.reittiopas.fi/public-ytv/fi/api/?user=#{USER}&pass=#{PASS}"
   
  ADDRESS_MATCHERS = {
    :id => /^\s*([^;]*)\;/,
    :city => /^[^;]*\;[^;]*\;([^;]*)/,
    :number => /^[^;]*\;\D*(\d+)/,
    :street => /^[^;]*\;([^;|\d]*)/,
    }

  LANG_CODE = "1"

  ACCURACY = {
    "Osoite ok" => 1,
    "Osoitenumero puuttui, käytettiin pelkkää kadunnimeä" => 2,
    "Käytettiin lähintä osoitenumeroa" => 3,
    "Käytettiin samankaltaista kadunnimeä" => 4,
    "Käytettiin samankaltaisinta kadunnimeä (valinta joukosta)" => 5
  }
      
end

require 'reittihaku/address'
require 'reittihaku/location'


def debug(string, level = :info)
  puts "#{level.to_s}: #{string}"
end
