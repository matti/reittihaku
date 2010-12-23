
require 'settings.rb'

require 'iconv'
require 'vendor/reittiopas/lib/reittiopas'


$: << File.expand_path(File.dirname(__FILE__))

require 'reittihaku/address'
require 'reittihaku/location'
require 'reittihaku/utils'
require 'reittihaku/monkey_patching'
