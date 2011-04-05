
raise "copy settings.rb.example to settings.rb" unless File.exists? "settings.rb"
require 'settings.rb'

raise "copy advanced_settings.rb.example to advanced_settings.rb" unless File.exists? "advanced_settings.rb"
require 'advanced_settings.rb'

raise "copy walker_settings.rb.example to walker_settings.rb" unless File.exists? "walker_settings.rb"
require 'walker_settings'


require 'iconv'
require 'vendor/reittiopas/lib/reittiopas'


$: << File.expand_path(File.dirname(__FILE__))

require 'reittihaku/address'
require 'reittihaku/location'
require 'reittihaku/utils'
require 'reittihaku/monkey_patching'
