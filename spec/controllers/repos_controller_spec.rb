require 'rails_helper'

RSpec.describe ReposController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Repo. As you add validations to Repo, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReposController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  

  describe "GET /repos" do
    it "Redirect to root" do
      get :index
      expect(response).to redirect_to("/")
    end
  end
  
  context "JSON" do
    render_views # Mandatory if we use response.body
    
    describe "GET /repos/:login/:repo" do
      it "JSON : List all contributors for a repository" do
        get :show_repo_details, {login: "ludovicdeluna", repo:"chartkick", :format => :json}
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json["repo"]["users"].length).to be >= 1
      end
    end
    
    describe "GET /repos/:login" do
      it "JSON : List all repositories for a user" do
        get :show_repo_list, {login: "ludovicdeluna", :format => :json}
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json["user"]["projects"].length).to be >= 1
      end
    end
    
    describe "POST /repos/:login/:repo/geoloc" do
      fixtures :cache_user
      
      it "JSON : Push list of geocodes data for all contributors" do
        params         = {login: "ludovicdeluna", repo: "chartkick", :format => :json}
        params[:users] = [{ login: "ludovicdeluna", geocode:"4448,1148", timestamp: CacheUser.first.get_timestamp}]
        post :update_geoloc, params
        expect(response).to be_success
      end
    end
  end

end
