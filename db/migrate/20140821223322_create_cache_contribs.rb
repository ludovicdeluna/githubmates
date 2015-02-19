class CreateCacheContribs < ActiveRecord::Migration
  def change
    create_table :cache_contribs do |t|
      t.integer :cache_repo_id,       null: false
      t.integer :cache_user_id,       null: false
      t.boolean :active_contributor,  null: false, default: true

      t.timestamps
    end
    add_index :cache_contribs, [:cache_repo_id, :cache_user_id], unique: true
  end
end
