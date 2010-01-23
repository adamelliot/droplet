$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'droplet'

KinsmenPool::Server::Base.run! :environment => :development
