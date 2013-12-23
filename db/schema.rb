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

ActiveRecord::Schema.define(version: 0) do

  create_table "pieces", :force => true do |t|
    t.integer  "position"
    t.integer  "account_id"
    t.integer  "creator_id"
    t.integer  "series_id"
    t.string   "title"
    t.text     "short_description"
    t.text     "description"
    t.date     "produced_on"
    t.string   "language"
    t.string   "related_website"
    t.text     "credits"
    t.text     "broadcast_history"
    t.text     "intro"
    t.text     "outro"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length"
    t.integer  "point_level"
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.text     "legacy_musical_works"
    t.integer  "episode_number"
    t.datetime "network_only_at"
    t.integer  "image_id"
    t.datetime "featured_at"
    t.boolean  "allow_comments",       :default => true
    t.float    "average_rating"
    t.integer  "npr_story_id"
    t.datetime "is_exportable_at"
    t.integer  "custom_points"
    t.datetime "is_shareable_at"
    t.datetime "has_custom_points_at"
    t.datetime "publish_notified_at"
    t.datetime "publish_on_valid_at"
    t.boolean  "publish_on_valid"
  end

  add_index "pieces", ["account_id"], :name => "pieces_account_id_fk"
  add_index "pieces", ["creator_id"], :name => "pieces_creator_id_fk"
  add_index "pieces", ["deleted_at"], :name => "deleted_at_idx"
  add_index "pieces", ["published_at"], :name => "by_published_at"
  add_index "pieces", ["series_id"], :name => "pieces_series_id_fk"

end
