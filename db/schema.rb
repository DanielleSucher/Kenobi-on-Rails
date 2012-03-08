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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120308023242) do

  create_table "results", :force => true do |t|
    t.text     "url"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "content"
  end

  add_index "results", ["user_id", "created_at"], :name => "index_results_on_user_id_and_created_at"

  create_table "users", :force => true do |t|
    t.string   "askme_id",         :limit => 20
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "total_words",                    :default => 0, :null => false
    t.integer  "total_docs",                     :default => 0, :null => false
    t.integer  "should_words",                   :default => 0, :null => false
    t.integer  "should_not_words",               :default => 0, :null => false
    t.integer  "should_docs",                    :default => 0, :null => false
    t.integer  "should_not_docs",                :default => 0, :null => false
  end

  add_index "users", ["askme_id"], :name => "index_users_on_askme_id"

  create_table "words", :force => true do |t|
    t.string   "wordstem",   :limit => 20
    t.integer  "should",                   :default => 0, :null => false
    t.integer  "should_not",               :default => 0, :null => false
    t.integer  "user_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "words", ["user_id", "created_at"], :name => "index_words_on_user_id_and_created_at"

end
