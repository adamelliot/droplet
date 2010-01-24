APP_ROOT = File.expand_path(File.dirname(__FILE__) + "/../")

module Droplet
  autoload :Server, "droplet/server"
  autoload :Models, "droplet/models"
end
