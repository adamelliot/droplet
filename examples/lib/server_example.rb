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

    it "uploads a file to the server" do
      post '/resources', "file" => uploaded_file
      last_response.should be_ok

      Droplet::Models::Resource.all.count.should == 1
    end
  end

  describe "GET to /resources" do
    it "returns a list of resouces" do
      get '/resources'
      last_response.should be_ok
    end
  end

end