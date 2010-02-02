require 'base64'

describe Droplet::Server do
  
  def uploaded_file
    Rack::Test::UploadedFile.new(File.dirname(__FILE__) + "/../data/test.jpg")
  end

  describe "GET to /" do
    before :each do
      get '/'
    end
    
    it "shows the main upload page" do
      last_response.should be_ok
    end
  end

  describe "POST to /resources" do
    before :each do
      Droplet::Models::Resource.all.destroy!
    end

    describe "not authenticated" do
      it "blocks access without any credentials" do
        post '/resources'
        last_response.status.should == 401
      end
      
#      it "block access with bad "
    end

    describe "authenticated" do
      before :each do
        ENV['password'] = 'p4ssw0rd'
        @creds = {'HTTP_AUTHORIZATION' => encode_credentials('droplet', 'p4ssw0rd')}
      end
      
      it "uploads a file to the server" do
        post '/resources', {"file" => uploaded_file}, @creds
        last_response.should be_ok

        Droplet::Models::Resource.all.count.should == 1
      end

      it "reports an error if no file is sent" do
        post '/resources', {}, @creds
        last_response.status.should == 409
      end
    end
    
    def encode_credentials(username, password)
      "Basic " + Base64.encode64("#{username}:#{password}")
    end
  end

  describe "GET to /resources" do
    it "returns json when queried with that format (js)" do
      get '/resources.js'
      last_response.body.should include('[', ']')
    end

    it "returns xml when queried with that format (xml)" do
      get '/resources.xml'
      last_response.body.should include('<', '>')
    end
    
    it "returns 404 when an invalid format is specified" do
      get "/resources.bad"
      last_response.status.should == 404
    end
  end

end