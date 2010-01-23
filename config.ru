$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'droplet'

run KinsmenPool::Server::Base
