#coding: UTF-8
class ReposController < ApplicationController
  require 'thread'
  
  before_action :set_repo,    only: [:show_repo_details]
  before_action :set_owner,   only: [:show_repo_list]
  protect_from_forgery except: :update_geoloc
  
  # GET /repos
  # GET /repos.json
  # - - - - -
  # Redirect all requests to /
  def index
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.json { render :index, status: :unprocessable_entity }
    end
  end


  # GET /repos/:login/:repo
  # GET /repos/:login/:repo.json
  # @repo, @path
  # - - - - -
  # Get repo details from GitHub and store the results in cache tables for next time.
  # Objectives : Retrieve localisation for each contributor to use in Google Geocoder API
  # Git Hub API rate limits up to 5k. I use 150 calls max per run to keep under rate limits.
  # So, be aware that limit of 60 calls for no authenticated user rise quickly (see config.yml)
  #
  def show_repo_details
    # Synchronize repo with Git Hub (1 day between refreshs)
    @repo.sync_github!(1.day).save!
    
    # Synchronize contributors (1 hour between refreshs)
    if @repo.sync_contribs_delay?(1.hour)
      github_contributors_login = @repo.get_github_contributors
      
      if github_contributors_login
        users = CacheUser.where(login: github_contributors_login)

        # Drop any relation with old contributors - I think i've wasted my time
        if users.length > 0
          CacheContrib.where(cache_repo_id: @repo).where.not(cache_user_id: users.map(&:id)).delete_all
        end

        # Add new contributors with empty personal data
        new_users = github_contributors_login - users.map(&:login)
        new_users.each do |github_login_new|
          CacheUser.create(login: github_login_new)
        end
        
        # Make link for each contributor
        current_contribs = CacheUser.joins(:cache_contribs).where(cache_contribs: {cache_repo_id: @repo.id})
        CacheUser.where(login: github_contributors_login).where.not(id: current_contribs).each do |user|
          user.cache_contribs.build(cache_repo: @repo)
          user.save
        end
      end
      
      @repo.upd_userlist_at = Time.now
      @repo.save!
    end
    
    # Load contributors from cache, contributors without personal data or too old are first
    # Nota : I use this method because a simple select order by synced_on show nil in first
    #        but I read than oracle put them at the end depending server configuration. This suck !
    @users = CacheUser.never_synced.only_repo(@repo).order(:updated_at)
    @users.merge CacheUser.synced_from(4.days).only_repo(@repo).order(:synced_on, :updated_at)
    
    # Update contributors personal data if too old or never updated
    if @users.length > 0
      maxlist = @users.length <= 148 ? @users.length : 148 # Not exceed 148 personal data requests
      
      # Synchronize personal data of contributors : Old method
      # -> not enought efficient with large contributors list
      # @users[0...maxlist].each {|contributor| contributor.reload.sync_github!(4.days).save!}

      # Synchronize personal data of contributors : Use threads for concurrent requests
      work_queue = Queue.new 
      # Add to the working queue all logins to proceed by threads
      @users[0...maxlist].map(&:login).each {|github_login| work_queue.push github_login}
      
      # Launch up to 10 threads
      # Warning : Each worker use a connection from ActiveRecord's pool. See database.yml for
      # set the pool size (count also the connection for this main thread).
      workers = (0...10).map do
        Thread.new do
          until work_queue.empty? do
            github_login = work_queue.pop(true) rescue nil
            if github_login
              user = CacheUser.where(login: github_login).first
              if user
                user.sync_github!(4.days).save!
              end
            end
          end
        end
      end
      workers.map(&:join) # Wait all threads finished before proceeding further    
    end
    # Reload fresh data.
    @users = CacheUser.only_repo(@repo)
    respond_to do |format|
      format.html { render }
      format.json { render :show_repo_details, status: :ok, location: @repo }
    end
  end
  
  # GET /repos/:login
  # GET /repos/:login.json
  # @owner
  # - - - - -
  # Search projects for one user in git hub and store in cache result
  # for next time. Delay between refresh is more large because the user
  # should not change so often
  def show_repo_list
    # Synchronize user's id_github with Git Hub (4 days between refreshs)
    @owner.sync_github!(4.days).save!
    
    # Synchronize list of user's projects (4 hours between refreshs)
    if @owner.sync_projects_delay?(4.hours)
      github_projects = @owner.get_github_projects
      
      if github_projects
        @owner.upd_projectlist_at = Time.now
        repos                     = CacheRepo.where(path: github_projects)
        
        # Drop any projects than no more exist in the user space
        if repos.length > 0
          CacheRepo.where.not(id: repos.map(&:id)).where(owner: @owner).delete_all
        end
        
        # Add any new project to this user
        (github_projects - repos.map(&:path)).each do |github_project_new|
          new_project = CacheRepo.new(path: github_project_new, owner: @owner)
          # Alway be aware of we have multiple workers and possibility concurrent insert
          if !new_project.save
            new_project = CacheRepo.where(path: github_project_new).first
            new_project.owner = @owner
            new_project.save!
          end
        end
      end
      @owner.save!
    end
    
    # Repository information will be refreshed only if the user request it
    # So, this action is more light than #show_repo_details
    @projects = CacheRepo.where(owner: @owner)
    respond_to do |format|
      format.html { render }
      format.json { render :show_repo_list, status: :ok, location: @owner }
    end
  end

  # POST /repos/:login/:repo/geoloc
  # POST /repos/:login/:repo/geoloc.json
  # @owner
  # - - - - -
  # Save geocodes informations for a list of users. Alway return "ok" even if
  # no update occure. User MUST exist in cache
  def update_geoloc
    # Too simple ! Need to check than every user are contributors for this project.
    # Ok, I admit this is realy not accurate for any security purpose... Curious to see what Novagile think about
    CacheUser.update_geocodes(geoloc_params)
    respond_to do |format|
      format.html { render text: "Request processed", status: "ok" }
      format.json { render text: {message: "Request processed"}, status: :ok}
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  private

  def cache_repo_url(repo)
    repo.github_reponame
  end

  def cache_user_url(user)
    user.login
  end

  # Set objects for use when access to full path repository
  def set_repo
    @path = "#{params[:login].strip}/#{params[:repo].strip}"
    @repo = CacheRepo.where(path: @path).first
    if !@repo
      @repo = CacheRepo.new(path: @path)
      @repo.save!
    end
  end

  # Set objects for use when access only to the :login in the repository path
  def set_owner
    @owner = CacheUser.where(login: params[:login]).first
    if !@owner
      @owner = CacheUser.new(login: params[:login])
      @owner.save!
    end
  end

  # Security for update of user's latlng in the case of bulk update
  def geoloc_params
    params.require(:users).map do |one_upd|
      {login: one_upd["login"], geocode: one_upd["geocode"], timestamp: one_upd["timestamp"]}
    end
  end

end