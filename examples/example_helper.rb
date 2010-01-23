$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'micronaut'
require 'droplet'
require 'rack/test'
require 'factory_girl'

require File.expand_path(File.dirname(__FILE__)) + '/factories'

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

Micronaut.configure do |configure|
  configure.color_enabled = not_in_editor?
  configure.filter_run :focused => true

  configure.include Rack::Test::Methods

  def app
    Rack::Lint.new(Droplet::Server.new)
  end
end

