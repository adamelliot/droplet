require 'sinatra/base'
require 'haml'
require 'sass'
require 'active_support'

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

    def self.get_with_format(path, &block)
      get %r{#{path}(\.(xml|js(on)?|html?))?} do
        wants = {}
        format = params[:captures] && params[:captures][1].to_sym || :html
        def wants.method_missing(type, *args, &handler)
          Sinatra::Base.send(:fail, "Unknown media type for respond_to: #{type}\nTry registering the extension with a mime type") if false
          self[type] = handler
        end

        block.bind(self).call(wants)
        wants[format].bind(self).call
      end
    end

    get '/' do
      haml :index
    end

    # Resource Routes
    get_with_format "/resources" do |wants|
      @resources = Droplet::Models::Resource.all

      wants.html { haml :resources }
      wants.js   { @resources.to_json }
      wants.xml  { @resources.to_xml }
    end

    post '/resources' do
      halt 409, "File doesn't appeart to have any content." unless params[:file][:tempfile].size > 0
      resource = Droplet::Models::Resource.new(:file => make_paperclip_mash(params[:file]))
      halt 409, "Something went wrong..." unless resource.save
    end
    
    # General Routes

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
