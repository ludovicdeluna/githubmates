# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140821223322) do

  create_table "cache_contribs", force: true do |t|
    t.integer  "cache_repo_id",                     null: false
    t.integer  "cache_user_id",                     null: false
    t.boolean  "active_contributor", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cache_contribs", ["cache_repo_id", "cache_user_id"], name: "index_cache_contribs_on_cache_repo_id_and_cache_user_id", unique: true, using: :btree

  create_table "cache_repos", force: true do |t|
    t.integer  "id_github",       default: 0,  null: false
    t.string   "path",            default: "", null: false
    t.integer  "owner_id",        default: 0,  null: false
    t.date     "synced_on"
    t.datetime "upd_userlist_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cache_repos", ["owner_id"], name: "index_cache_repos_on_owner_id", using: :btree
  add_index "cache_repos", ["path"], name: "index_cache_repos_on_path", unique: true, using: :btree

  create_table "cache_users", force: true do |t|
    t.integer  "id_github",          default: 0,  null: false
    t.string   "login",              default: "", null: false
    t.string   "fullname",           default: "", null: false
    t.string   "location",           default: "", null: false
    t.string   "avatar",             default: "", null: false
    t.string   "latlng",             default: "", null: false
    t.date     "synced_on"
    t.datetime "upd_projectlist_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cache_users", ["id_github"], name: "index_cache_users_on_id_github", using: :btree
  add_index "cache_users", ["login"], name: "index_cache_users_on_login", unique: true, using: :btree

end
