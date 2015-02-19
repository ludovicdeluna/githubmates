require 'rails_helper'

RSpec.describe CacheRepo, "#github_username", :type => :model do
  fixtures :cache_repo
  
  it "Show the login owner" do
    expect(CacheRepo.first.github_username).to eq("ludovicdeluna")
  end
end

RSpec.describe CacheRepo, "#github_reponame", :type => :model do
  fixtures :cache_repo
  
  it "Show the project name" do
    expect(CacheRepo.first.github_reponame).to eq("chartkick")
  end
end

RSpec.describe CacheRepo, "#sync_contribs_delay?", :type => :model do
  fixtures :cache_repo
  before (:each) do
    @repo = CacheRepo.first
  end
  
  it "No (false) : List of contributors is within 1 hour old" do
    @repo.upd_userlist_at = (Time.now)
    @repo.save
    expect(@repo.sync_contribs_delay?).to eq(false)
  end
  
  it "Yes (true) : List of contributors is more than 1 hour old" do
    @repo.upd_userlist_at = (Time.now - 1.hour)
    @repo.save
    expect(@repo.sync_contribs_delay?).to eq(true)
  end
end

RSpec.describe CacheRepo, "#sync_github!", :type => :model do
  fixtures :cache_repo
  
  it "Get an update from Github service" do
    @repo = CacheRepo.create(path: CacheRepo.first.path)
    @repo.sync_github!
    @repo.save
    expect(@repo.id_github).not_to eq(0)
    expect(@repo.synced_on).not_to be nil
    expect(@repo.github_access_failed?).to eq(false)
  end
end

RSpec.describe CacheRepo, "#get_github_contributors" , :type => :model do
  fixtures :cache_repo
  before(:each) do
    @repo = CacheRepo.create(path: CacheRepo.first.path, synced_on: Date.today)
  end
  after(:all) do
    CacheRepo.delete_all
  end

  # Again, we don't list ALL users because I don't care about API pagination
  # This is only for Novagile's test
  it "Get list of contributors from Github service" do
    contributors = @repo.get_github_contributors
    expect(@repo.github_access_failed?).to eq(false)
    expect(contributors).not_to be nil
    expect(contributors.length).to be > 0
  end
end
