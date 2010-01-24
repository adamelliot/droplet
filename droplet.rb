$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'droplet'

Droplet::Server.run! :environment => :development
