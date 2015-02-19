require 'rails_helper'

RSpec.describe CacheUser, "#sync_github", :type => :model do
  fixtures :cache_user
  
  it "Get an update from Github service" do
    expect(CacheUser.first.sync_github!.id_github).to be 6412308
  end
end

RSpec.describe CacheUser, "#sync_projects_delay?", :type => :model do
  fixtures :cache_user
  before (:each) do
    @user = CacheUser.first
  end
  
  it "No (false) : List of projects is within 4 hours old" do
    @user.upd_projectlist_at = (Time.now)
    @user.save
    expect(@user.sync_projects_delay?).to eq(false)
  end
  
  it "Yes (true) : List of projects is more than 4 hours old" do
    @user.upd_projectlist_at = (Time.now - 4.hour)
    @user.save
    expect(@user.sync_projects_delay?).to eq(true)
  end
end

RSpec.describe CacheUser, "#get_github_projects" do
  fixtures :cache_user
  before (:all) do
    @user = CacheUser.first
  end
  
  it "Get list of user's projects from Github service" do
    list = @user.get_github_projects
    expect(@user.github_access_failed?).to be false
    expect(list).not_to be nil
    expect(list.length).to be > 0
  end
end

RSpec.describe CacheUser, "::update_geocodes" , :type => :model do
  fixtures :cache_user
  before(:each, use_json: true) do
    @json = {
      users: [{ login: "ludovicdeluna", geocode: "4448,1148", timestamp: CacheUser.first.get_timestamp}]
    }
  end
  after(:all) do
    CacheUser.delete_all
  end

  it "Update geocodes data for a list of users",  use_json: true do
    usrlist = @json[:users]
    CacheUser.update_geocodes(usrlist)
    @ludovic = CacheUser.first
    expect(@ludovic.latlng).to eq("4448,1148")
  end
end