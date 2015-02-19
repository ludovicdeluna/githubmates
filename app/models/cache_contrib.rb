class CacheContrib < ActiveRecord::Base
  # - - Relations - -
  belongs_to :cache_user
  belongs_to :cache_repo
  
end
