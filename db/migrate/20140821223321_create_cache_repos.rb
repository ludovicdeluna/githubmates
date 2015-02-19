class CreateCacheRepos < ActiveRecord::Migration
  def change
    create_table :cache_repos do |t|
      t.integer   :id_github,           null: false,  default: 0
      t.string    :path,                null: false,  default: ""
      t.integer   :owner_id,            null: false,  default: 0
      t.date      :synced_on,           null: true
      t.datetime  :upd_userlist_at,     null: true

      t.timestamps
    end
    add_index :cache_repos, :path,      unique: true
    add_index :cache_repos, :owner_id
  end
end
