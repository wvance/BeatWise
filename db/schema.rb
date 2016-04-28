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

ActiveRecord::Schema.define(version: 20160427190103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clusters", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id"
    t.integer  "minimum"
    t.integer  "maximum"
    t.string   "average"
    t.string   "average_slope"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "clusters", ["user_id"], name: "index_clusters_on_user_id", using: :btree

  create_table "contents", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cluster_id"
    t.string   "title"
    t.string   "body"
    t.string   "parent"
    t.string   "location"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal"
    t.string   "country"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "external_id"
    t.string   "external_link"
    t.string   "media_link"
    t.string   "image"
    t.string   "kind"
    t.string   "provider"
    t.text     "log"
    t.boolean  "active"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "contents", ["cluster_id"], name: "index_contents_on_cluster_id", using: :btree
  add_index "contents", ["user_id"], name: "index_contents_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "refresh_token"
    t.string   "expires_at"
    t.string   "secret"
    t.string   "username"
    t.string   "email"
    t.string   "identity_log"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "recipient_id"
    t.datetime "read_at"
    t.string   "action"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "content_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tags", ["content_id"], name: "index_tags_on_content_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "contents", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "tags", "contents"
end
