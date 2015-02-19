class CacheUser < ActiveRecord::Base
  # - - Relations - -
  has_many :cache_contribs
  has_many :cache_repos, through: :cache_contribs
  accepts_nested_attributes_for :cache_repos
  validates_uniqueness_of :login
  
  # - - Scopes - -
  scope :only_repo,     lambda {|repo| joins(:cache_repos).where(cache_repos: {id: repo})}
  scope :never_synced,  lambda {where(synced_on: nil)}
  scope :synced,        lambda {where.not(synced_on: nil)}
  scope :synced_from,   lambda {|delay = 4.days| where("synced_on <= (?)", Date.today - delay)}
  
  def github_access_failed?
    @github_access_failed ||= false
    return @github_access_failed
  end
  
  def sync_projects_delay?(delay = 4.hours)
    self.id_github > 0 && (!self.upd_projectlist_at || self.upd_projectlist_at <= Time.now - delay)
  end
  
  def sync_github!(delay = 4.days)
    if !self.synced_on || self.synced_on <= Date.today - delay
      begin
        users = Github::Client::Users.new(basic_auth: APP_CONFIG["github_key"])
        user  = users.get(user: self.login)
      rescue
        @github_access_failed = true
      ensure
        self.synced_on  = Date.today
      end
      unless @github_access_failed
        self.id_github = user.id
        self.location  = (user.location != nil ?    user.location   : "") if user.respond_to? :location
        self.avatar    = (user.avatar_url != nil ?  user.avatar_url : "") if user.respond_to? :avatar_url
        self.fullname  = (user.name != nil ?    user.name   : "") if user.respond_to? :name
        self.synced_on = Date.today
      end
    end
    self
  end
  
  def get_github_projects
    list = []
    begin
      # Return list of all projects for this user (again, no pagination like for cache_repo)
      repo = Github::Client::Repos.new(basic_auth: APP_CONFIG["github_key"])
      repo.list(user: self.login) do |repo|
        list.push("#{self.login}/#{repo.name}")
      end
    rescue
      list = nil
      @github_access_failed = true    
    end
    list
  end
  
  def get_timestamp
    self.updated_at.utc.to_i
  end
  
  def self.update_geocodes(users)
    users.each do |usr_upd|
      timestamp = Time.at(usr_upd[:timestamp]) rescue nil
      user = CacheUser.where(login: usr_upd[:login], updated_at: timestamp).first if timestamp
      if user && user.updated_at == Time.at(timestamp)
        user.latlng = usr_upd[:geocode]
        user.save!
      end
    end
  end

end
