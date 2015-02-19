class CacheRepo < ActiveRecord::Base
  # - - Relations - -
  belongs_to  :owner, :class_name => :CacheUser, :foreign_key => :owner_id
  has_many    :cache_contribs
  has_many    :cache_users, through: :cache_contribs
  accepts_nested_attributes_for :cache_users
  validates_uniqueness_of :path
  
  # - - Scopes - -
  scope :only_user,     lambda {|user| joins(:cache_users).where(cache_users: {id: user})}
  
  def github_username
    self.path.split("/").first
  end
  
  def github_reponame
    self.path.split("/").last
  end
  
  def sync_contribs_delay?(delay = 1.hour)
    self.id_github > 0 && (!self.upd_userlist_at || self.upd_userlist_at <= Time.now - delay)
  end
  
  def github_access_failed?
    @github_access_failed ||= false
    return @github_access_failed
  end
  
  def sync_github!(delay = 1.day)
    if !self.synced_on || self.synced_on <= Date.today - delay
      begin
        repo = Github::Client::Repos.new(basic_auth: APP_CONFIG["github_key"])
        repo_github = repo.get(user: self.github_username, repo: self.github_reponame)
        repo_owner  = repo_github.owner
      rescue
        @github_access_failed = true
      ensure
        self.synced_on  = Date.today
      end
      unless @github_access_failed
        self.id_github = repo_github.id
        owner = CacheUser.where(login: repo_owner.login).first
        unless owner
          self.build_owner(login: self.github_username)
        else
          self.owner = owner
        end
        self.owner.id_github = repo_owner.id
        self.owner.avatar = (repo_owner.avatar_url != nil ? repo_owner.avatar_url : "") if repo_owner.respond_to? :avatar_url
        self.owner.location = (repo_owner.location != nil ? repo_owner.location : "") if repo_owner.respond_to? :location
        self.owner.synced_on = Date.today
      end
    end
    self
  end

  def get_github_contributors
    list = []
    begin
      # Return list of all contributors (be aware on pagination, don't care here because Novagile's test only)
      repo = Github::Client::Repos.new(basic_auth: APP_CONFIG["github_key"])
      repo.contributors(user: self.github_username, repo: self.github_reponame) do |contributor|
        list.push(contributor.login)
      end
    rescue
      @github_access_failed = true
      list = nil
    end
    list
  end
  
end
