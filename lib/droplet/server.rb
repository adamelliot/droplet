require 'sinatra/base'
require 'haml'
require 'sass'

module Droplet
  class Server < Sinatra::Base
    enable :logging, :static
    set :root, APP_ROOT

    configure do
      set :haml, {:format => :html5}
    end

    configure :production do
      set :sass, {:style => :compact}
    end

    get '/' do
      haml :index
    end

    # Resource methods

    get '/resources' do
      @resources = Droplet::Models::Resource.all
      haml :resources
    end

    post '/resources' do
      halt 409, "File doesn't appeart to have any content." unless params[:file][:tempfile].size > 0
      resource = Droplet::Models::Resource.new(:file => make_paperclip_mash(params[:file]))
      halt 409, "Something went wrong..." unless resource.save

#      File.new(params[:file][:tempfile])
      
      params[:file].inspect
      #resource.file_file_size
    end

    get '/application.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :application
    end

    not_found do
      "Not sure what you're looking for, but I don't think it's here..."
    end
    
    private
      # Creates a Mash that has the props paperclip expects
      def make_paperclip_mash(file_hash)
        mash = Mash.new
        mash['tempfile'] = file_hash[:tempfile]
        mash['filename'] = file_hash[:filename]
        mash['content_type'] = file_hash[:type]
        mash['size'] = file_hash[:tempfile].size
        mash
      end
  end
end
