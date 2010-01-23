require 'sinatra/base'
require 'haml'
require 'sass'

module Droplet
  class Server < Sinatra::Base
    enable :logging, :static
    set :root, File.dirname(__FILE__)

    configure do
      set :haml, {:format => :html5 }
    end

    configure :production do
      set :sass, {:style => :compact }
    end

    get '/' do
      haml :index
    end

    get '/application.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :application
    end

    not_found do
      "Not sure what you're looking for, but I don't think it's here..."
    end
  end
end
