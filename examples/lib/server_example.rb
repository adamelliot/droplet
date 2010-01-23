describe Droplet::Server do

  describe "GET to /" do
    before :each do
      get '/'
    end
    
    it "shows the main upload page" do
      last_response.should be_ok
    end
  end

  describe "POST to /upload" do
    it "uploads a file to the server" do
      post 
    end
  end

end