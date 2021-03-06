# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100306164113) do

  create_table "documents", :force => true do |t|
    t.string   "human_name"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "voting_state", :default => "brainstorm"
  end

  create_table "forum_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories", :force => true do |t|
    t.string   "name",           :limit => 80
    t.string   "path",           :limit => 256
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_id"
    t.text     "content"
    t.text     "commit_message"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "depth"
    t.string   "can_changed_by"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
