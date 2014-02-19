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
    t.datetime "promos_only_at"
    t.string   "episode_identifier"
  end

  add_index "pieces", ["account_id"], :name => "pieces_account_id_fk"
  add_index "pieces", ["creator_id"], :name => "pieces_creator_id_fk"
  add_index "pieces", ["published_at"], :name => "by_published_at"
  add_index "pieces", ["series_id"], :name => "pieces_series_id_fk"

  create_table "audio_files", :force => true do |t|
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "audio_version_id"
    t.integer  "account_id"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "parent_id"
    t.string   "label"
    t.integer  "length"
    t.integer  "layer"
    t.integer  "bit_rate",                                       :default => 0,   :null => false
    t.decimal  "frequency",        :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.string   "channel_mode"
    t.string   "status"
    t.string   "format"
    t.datetime "deleted_at"
    t.string   "listenable_type"
    t.integer  "listenable_id"
    t.string   "upload_path"
    t.integer  "current_job_id"
  end

  add_index "audio_files", ["account_id"], :name => "audio_files_account_id_fk"
  add_index "audio_files", ["audio_version_id"], :name => "audio_files_audio_version_id_fk"
  add_index "audio_files", ["listenable_type", "listenable_id"], :name => "listenable_idx"
  add_index "audio_files", ["parent_id"], :name => "audio_files_parent_id_fk"
  add_index "audio_files", ["position"], :name => "position_idx"
  add_index "audio_files", ["status"], :name => "status_idx"

  create_table "audio_versions", :force => true do |t|
    t.integer  "piece_id"
    t.string   "label"
    t.text     "content_advisory"
    t.text     "timing_and_cues"
    t.text     "transcript"
    t.boolean  "news_hole_break"
    t.boolean  "floating_break"
    t.boolean  "bottom_of_hour_break"
    t.boolean  "twenty_forty_break"
    t.boolean  "promos"
    t.datetime "deleted_at"
    t.integer  "audio_version_template_id"
  end

  add_index "audio_versions", ["piece_id"], :name => "audio_versions_piece_id_fk"

  create_table "accounts", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "opener_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "station_call_letters"
    t.string   "station_frequency"
    t.string   "station_coverage_area"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.integer  "contact_id"
    t.datetime "deleted_at"
    t.text     "request_description"
    t.text     "description"
    t.string   "opener_role"
    t.string   "intended_uses"
    t.integer  "address_id"
    t.datetime "request_licensing_at"
    t.string   "contact_first_name"
    t.string   "contact_last_name"
    t.string   "station_total_revenue"
    t.integer  "station_total_revenue_year"
    t.string   "planned_programming"
    t.string   "path"
    t.string   "phone"
    t.datetime "outside_purchaser_at"
    t.boolean  "outside_purchaser_default_option"
    t.integer  "total_points_earned",              :default => 0
    t.integer  "total_points_spent",               :default => 0
    t.integer  "additional_size_limit",            :default => 0
    t.string   "api_key"
    t.integer  "npr_org_id"
    t.string   "delivery_ftp_password"
    t.string   "stripe_customer_token"
    t.string   "card_type"
    t.integer  "card_last_four"
    t.integer  "card_exp_month"
    t.integer  "card_exp_year"
  end

  add_index "accounts", ["api_key"], :name => "index_accounts_on_api_key"
  add_index "accounts", ["contact_id"], :name => "accounts_contact_id_fk"
  add_index "accounts", ["opener_id"], :name => "accounts_opener_id_fk"

  create_table "addresses", :force => true do |t|
    t.integer "addressable_id"
    t.string  "addressable_type"
    t.string  "street_1"
    t.string  "street_2"
    t.string  "street_3"
    t.string  "postal_code"
    t.string  "city"
    t.string  "state"
    t.string  "country"
  end

  add_index "addresses", ["addressable_type", "addressable_id"], :name => "index_addresses_on_addressable_type_and_addressable_id"

  create_table "account_images", :force => true do |t|
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.float   "aspect_ratio"
    t.integer "account_id"
  end

  add_index "account_images", ["account_id"], :name => "account_images_account_id_fk"

  create_table "piece_images", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.float    "aspect_ratio"
    t.integer  "piece_id"
    t.string   "caption"
    t.string   "credit"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "piece_images", ["piece_id"], :name => "piece_images_piece_id_fk"

  create_table "licenses", :force => true do |t|
    t.integer  "piece_id"
    t.string   "website_usage"
    t.string   "allow_edit"
    t.text     "additional_terms"
    t.integer  "version_user_id"
    t.integer  "version"
    t.datetime "deleted_at"
  end

  add_index "licenses", ["piece_id"], :name => "licenses_piece_id_fk"

end
