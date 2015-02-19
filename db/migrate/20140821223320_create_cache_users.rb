class CreateCacheUsers < ActiveRecord::Migration
  def change
    create_table :cache_users do |t|
      t.integer   :id_github,           null: false, default: 0
      t.string    :login,               null: false, default: ""
      t.string    :fullname,            null: false, default: ""
      t.string    :location,            null: false, default: ""
      t.string    :avatar,              null: false, default: ""
      t.string    :latlng,              null: false, default: ""
      t.date      :synced_on,           null: true
      t.datetime  :upd_projectlist_at,     null: true

      t.timestamps
    end
    add_index     :cache_users, :id_github
    add_index     :cache_users, :login,     unique: true
  end
end
