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

ActiveRecord::Schema.define(version: 6) do

  create_table "account_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.integer  "account_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_path",  limit: 255
    t.string   "status",       limit: 255
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.string   "purpose",      limit: 255
  end

  add_index "account_images", ["account_id"], name: "account_images_account_id_fk", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "type",                             limit: 255
    t.string   "name",                             limit: 255
    t.integer  "opener_id",                        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                           limit: 255
    t.string   "station_call_letters",             limit: 255
    t.string   "station_frequency",                limit: 255
    t.string   "station_coverage_area",            limit: 255
    t.string   "contact_phone",                    limit: 255
    t.string   "contact_email",                    limit: 255
    t.integer  "contact_id",                       limit: 4
    t.datetime "deleted_at"
    t.text     "request_description",              limit: 65535
    t.text     "description",                      limit: 65535
    t.string   "opener_role",                      limit: 255
    t.string   "intended_uses",                    limit: 255
    t.integer  "address_id",                       limit: 4
    t.datetime "request_licensing_at"
    t.string   "contact_first_name",               limit: 255
    t.string   "contact_last_name",                limit: 255
    t.string   "station_total_revenue",            limit: 255
    t.integer  "station_total_revenue_year",       limit: 4
    t.string   "planned_programming",              limit: 255
    t.string   "path",                             limit: 255
    t.string   "phone",                            limit: 255
    t.datetime "outside_purchaser_at"
    t.boolean  "outside_purchaser_default_option"
    t.integer  "total_points_earned",              limit: 4,     default: 0
    t.integer  "total_points_spent",               limit: 4,     default: 0
    t.integer  "additional_size_limit",            limit: 4,     default: 0
    t.string   "api_key",                          limit: 255
    t.integer  "npr_org_id",                       limit: 4
    t.string   "delivery_ftp_password",            limit: 255
    t.string   "stripe_customer_token",            limit: 255
    t.string   "card_type",                        limit: 255
    t.integer  "card_last_four",                   limit: 4
    t.integer  "card_exp_month",                   limit: 4
    t.integer  "card_exp_year",                    limit: 4
  end

  add_index "accounts", ["api_key"], name: "index_accounts_on_api_key", using: :btree
  add_index "accounts", ["contact_id"], name: "accounts_contact_id_fk", using: :btree
  add_index "accounts", ["opener_id"], name: "accounts_opener_id_fk", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "addressable_id",   limit: 4
    t.string   "addressable_type", limit: 255
    t.string   "street_1",         limit: 255
    t.string   "street_2",         limit: 255
    t.string   "street_3",         limit: 255
    t.string   "postal_code",      limit: 255
    t.string   "city",             limit: 255
    t.string   "state",            limit: 255
    t.string   "country",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree

  create_table "audio_file_templates", force: :cascade do |t|
    t.integer  "audio_version_template_id", limit: 4
    t.integer  "position",                  limit: 4
    t.string   "label",                     limit: 255
    t.integer  "length_minimum",            limit: 4
    t.integer  "length_maximum",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audio_files", force: :cascade do |t|
    t.integer  "position",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "audio_version_id", limit: 4
    t.integer  "account_id",       limit: 4
    t.integer  "size",             limit: 4
    t.string   "content_type",     limit: 255
    t.string   "filename",         limit: 255
    t.integer  "parent_id",        limit: 4
    t.string   "label",            limit: 255
    t.integer  "length",           limit: 4
    t.integer  "layer",            limit: 4
    t.integer  "bit_rate",         limit: 4,                           default: 0,   null: false
    t.decimal  "frequency",                    precision: 5, scale: 2, default: 0.0, null: false
    t.string   "channel_mode",     limit: 255
    t.string   "status",           limit: 255
    t.string   "format",           limit: 255
    t.text     "status_msg",       limit: 65535
    t.datetime "deleted_at"
    t.string   "listenable_type",  limit: 255
    t.integer  "listenable_id",    limit: 4
    t.string   "upload_path",      limit: 255
    t.integer  "current_job_id",   limit: 4
  end

  add_index "audio_files", ["account_id"], name: "audio_files_account_id_fk", using: :btree
  add_index "audio_files", ["audio_version_id"], name: "audio_files_audio_version_id_fk", using: :btree
  add_index "audio_files", ["listenable_type", "listenable_id"], name: "listenable_idx", using: :btree
  add_index "audio_files", ["parent_id"], name: "audio_files_parent_id_fk", using: :btree
  add_index "audio_files", ["position"], name: "position_idx", using: :btree
  add_index "audio_files", ["status"], name: "status_idx", using: :btree

  create_table "audio_version_templates", force: :cascade do |t|
    t.integer  "series_id",      limit: 4
    t.string   "label",          limit: 255
    t.boolean  "promos"
    t.integer  "length_minimum", limit: 4
    t.integer  "segment_count",  limit: 4
    t.integer  "length_maximum", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audio_versions", force: :cascade do |t|
    t.integer  "piece_id",                  limit: 4
    t.string   "label",                     limit: 255
    t.string   "explicit",                  limit: 255
    t.text     "content_advisory",          limit: 65535
    t.text     "timing_and_cues",           limit: 65535
    t.text     "transcript",                limit: 65535
    t.text     "status_msg",                limit: 65535
    t.string   "status",                    limit: 255
    t.boolean  "news_hole_break"
    t.boolean  "floating_break"
    t.boolean  "bottom_of_hour_break"
    t.boolean  "twenty_forty_break"
    t.boolean  "promos"
    t.datetime "deleted_at"
    t.integer  "audio_version_template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audio_versions", ["piece_id"], name: "audio_versions_piece_id_fk", using: :btree

  create_table "distributions", force: :cascade do |t|
    t.string   "type",                      limit: 255
    t.string   "distributable_type",        limit: 255
    t.integer  "distributable_id",          limit: 4
    t.integer  "audio_version_template_id", limit: 4
    t.string   "url",                       limit: 255
    t.string   "guid",                      limit: 255
    t.text     "properties",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distributions", ["distributable_type", "distributable_id"], name: "index_distributions_on_distributable_type_and_distributable_id", using: :btree

  create_table "formats", force: :cascade do |t|
    t.integer "piece_id", limit: 4
    t.string  "name",     limit: 255
  end

  add_index "formats", ["piece_id"], name: "formats_piece_id_fk", using: :btree

  create_table "podcast_imports", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "series_id",  limit: 4
    t.string   "url",        limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", force: :cascade do |t|
    t.integer  "piece_id",         limit: 4
    t.string   "website_usage",    limit: 255
    t.string   "allow_edit",       limit: 255
    t.text     "additional_terms", limit: 65535
    t.integer  "version_user_id",  limit: 4
    t.integer  "version",          limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "licenses", ["piece_id"], name: "licenses_piece_id_fk", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "request",    limit: 65535
    t.boolean  "approved"
    t.datetime "created_at"
    t.string   "role",       limit: 255
    t.datetime "updated_at"
  end

  create_table "musical_works", force: :cascade do |t|
    t.integer  "position",       limit: 4
    t.integer  "piece_id",       limit: 4
    t.string   "title",          limit: 255
    t.string   "artist",         limit: 255
    t.string   "album",          limit: 255
    t.string   "label",          limit: 255
    t.integer  "year",           limit: 4
    t.integer  "excerpt_length", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "musical_works", ["piece_id"], name: "musical_works_piece_id_fk", using: :btree

  create_table "network_memberships", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "network_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", force: :cascade do |t|
    t.integer  "account_id",            limit: 4
    t.string   "name",                  limit: 255
    t.string   "description",           limit: 255
    t.string   "pricing_strategy",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "publishing_strategy",   limit: 255, default: "", null: false
    t.string   "notification_strategy", limit: 255, default: "", null: false
    t.string   "path",                  limit: 255
  end

  create_table "piece_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.integer  "piece_id",     limit: 4
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.integer  "position",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_path",  limit: 255
    t.string   "status",       limit: 255
    t.string   "purpose",      limit: 255
  end

  add_index "piece_images", ["piece_id"], name: "piece_images_piece_id_fk", using: :btree

  create_table "pieces", force: :cascade do |t|
    t.integer  "position",                limit: 4
    t.integer  "account_id",              limit: 4
    t.integer  "creator_id",              limit: 4
    t.integer  "series_id",               limit: 4
    t.string   "title",                   limit: 255
    t.text     "short_description",       limit: 65535
    t.text     "description",             limit: 65535
    t.date     "produced_on"
    t.string   "language",                limit: 255
    t.string   "related_website",         limit: 255
    t.text     "credits",                 limit: 65535
    t.text     "broadcast_history",       limit: 65535
    t.text     "intro",                   limit: 65535
    t.text     "outro",                   limit: 65535
    t.string   "status",                  limit: 255
    t.text     "status_msg",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",                  limit: 4
    t.integer  "point_level",             limit: 4
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.text     "legacy_musical_works",    limit: 65535
    t.integer  "episode_number",          limit: 4
    t.datetime "network_only_at"
    t.integer  "image_id",                limit: 4
    t.datetime "featured_at"
    t.boolean  "allow_comments",                        default: true
    t.float    "average_rating",          limit: 24
    t.integer  "npr_story_id",            limit: 4
    t.datetime "is_exportable_at"
    t.integer  "custom_points",           limit: 4
    t.datetime "is_shareable_at"
    t.datetime "has_custom_points_at"
    t.boolean  "publish_on_valid"
    t.datetime "publish_notified_at"
    t.datetime "publish_on_valid_at"
    t.datetime "promos_only_at"
    t.string   "episode_identifier",      limit: 255
    t.string   "app_version",             limit: 255,   default: "v3", null: false
    t.string   "marketplace_subtitle",    limit: 255
    t.text     "marketplace_information", limit: 65535
    t.integer  "network_id",              limit: 4
    t.datetime "released_at"
  end

  add_index "pieces", ["account_id"], name: "pieces_account_id_fk", using: :btree
  add_index "pieces", ["created_at", "published_at"], name: "created_published_index", using: :btree
  add_index "pieces", ["creator_id"], name: "pieces_creator_id_fk", using: :btree
  add_index "pieces", ["deleted_at", "published_at", "network_only_at"], name: "public_pieces_index", using: :btree
  add_index "pieces", ["deleted_at"], name: "deleted_at_idx", using: :btree
  add_index "pieces", ["episode_number", "series_id"], name: "index_pieces_on_episode_number_and_series_id", using: :btree
  add_index "pieces", ["network_id", "network_only_at", "deleted_at"], name: "index_pieces_on_network_id_and_network_only_at_and_deleted_at", using: :btree
  add_index "pieces", ["published_at"], name: "by_published_at", using: :btree
  add_index "pieces", ["series_id", "deleted_at"], name: "series_episodes", using: :btree
  add_index "pieces", ["series_id"], name: "pieces_series_id_fk", using: :btree

  create_table "playlist_sections", force: :cascade do |t|
    t.integer  "playlist_id", limit: 4
    t.string   "title",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",    limit: 4
    t.text     "comment",     limit: 65535
  end

  create_table "playlistings", force: :cascade do |t|
    t.integer  "playlist_section_id", limit: 4
    t.integer  "playlistable_id",     limit: 4
    t.string   "playlistable_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",            limit: 4
    t.text     "comment",             limit: 65535
    t.string   "editors_title",       limit: 255
  end

  create_table "playlists", force: :cascade do |t|
    t.string   "title",                  limit: 255
    t.integer  "account_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",            limit: 65535
    t.integer  "position",               limit: 4
    t.datetime "curated_at"
    t.datetime "featured_at"
    t.string   "type",                   limit: 255
    t.datetime "deleted_at"
    t.datetime "published_at"
    t.datetime "allow_free_purchase_at"
    t.string   "path",                   limit: 255
  end

  create_table "producers", force: :cascade do |t|
    t.integer  "piece_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "invited_at"
    t.string   "email",      limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "producers", ["piece_id"], name: "producers_piece_id_fk", using: :btree
  add_index "producers", ["user_id"], name: "producers_user_id_fk", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.integer  "seller_account_id",    limit: 4
    t.integer  "purchaser_account_id", limit: 4
    t.integer  "purchaser_id",         limit: 4
    t.integer  "purchased_id",         limit: 4
    t.integer  "license_version",      limit: 4
    t.datetime "purchased_at"
    t.date     "expires_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",                            precision: 9, scale: 2
    t.string   "unit",                 limit: 255
    t.string   "payment_type",         limit: 255
    t.decimal  "royalty_base",                     precision: 9, scale: 2
    t.decimal  "royalty_bonus",                    precision: 9, scale: 2
    t.decimal  "royalty_subsidy",                  precision: 9, scale: 2
    t.string   "purchased_type",       limit: 255
    t.integer  "network_id",           limit: 4
  end

  add_index "purchases", ["purchaser_account_id"], name: "purchases_purchaser_account_id_fk", using: :btree
  add_index "purchases", ["purchaser_id"], name: "purchases_purchaser_id_fk", using: :btree
  add_index "purchases", ["seller_account_id"], name: "purchases_seller_account_id_fk", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.integer  "series_id",  limit: 4
    t.integer  "day",        limit: 4
    t.integer  "hour",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["series_id"], name: "index_schedules_on_series_id", using: :btree

  create_table "series", force: :cascade do |t|
    t.integer  "account_id",                   limit: 4
    t.string   "title",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "short_description",            limit: 65535
    t.text     "description",                  limit: 65535
    t.string   "frequency",                    limit: 255
    t.text     "production_notes",             limit: 65535
    t.integer  "creator_id",                   limit: 4
    t.datetime "deleted_at"
    t.string   "file_prefix",                  limit: 255
    t.string   "time_zone",                    limit: 255
    t.integer  "episode_start_number",         limit: 4
    t.datetime "episode_start_at"
    t.string   "subscription_approval_status", limit: 255
    t.integer  "evergreen_piece_id",           limit: 4
    t.integer  "due_before_hours",             limit: 4
    t.datetime "prx_billing_at"
    t.integer  "promos_days_early",            limit: 4
    t.datetime "subauto_bill_me_at"
    t.datetime "subscriber_only_at"
    t.string   "app_version",                  limit: 255,   default: "v3", null: false
  end

  add_index "series", ["account_id"], name: "index_series_on_account_id", using: :btree

  create_table "series_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.integer  "series_id",    limit: 4
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_path",  limit: 255
    t.string   "status",       limit: 255
    t.string   "purpose",      limit: 255
  end

  add_index "series_images", ["series_id"], name: "series_images_series_id_fk", using: :btree

  create_table "story_distributions", force: :cascade do |t|
    t.string   "type",            limit: 255
    t.integer  "distribution_id", limit: 4
    t.integer  "piece_id",        limit: 4
    t.string   "url",             limit: 255
    t.string   "guid",            limit: 255
    t.text     "properties",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "story_distributions", ["distribution_id", "piece_id"], name: "index_story_distributions_on_distribution_id_and_piece_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "tones", force: :cascade do |t|
    t.integer "piece_id", limit: 4
    t.string  "name",     limit: 255
  end

  add_index "tones", ["piece_id"], name: "tones_piece_id_fk", using: :btree

  create_table "topics", force: :cascade do |t|
    t.integer "piece_id", limit: 4
    t.string  "name",     limit: 255
  end

  add_index "topics", ["piece_id"], name: "topics_piece_id_fk", using: :btree

  create_table "user_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_path",  limit: 255
    t.string   "status",       limit: 255
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.string   "purpose",      limit: 255
  end

  add_index "user_images", ["user_id"], name: "user_images_user_id_fk", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       limit: 40
    t.string   "first_name",                limit: 255
    t.string   "last_name",                 limit: 255
    t.datetime "deleted_at"
    t.datetime "migrated_at"
    t.string   "old_password",              limit: 255
    t.datetime "user_agreement_at"
    t.datetime "subscribed_at"
    t.string   "day_phone",                 limit: 255
    t.string   "eve_phone",                 limit: 255
    t.string   "im_name",                   limit: 255
    t.text     "bio",                       limit: 65535
    t.integer  "account_id",                limit: 4
    t.string   "title",                     limit: 255
    t.string   "favorite_shows",            limit: 255
    t.string   "influences",                limit: 255
    t.boolean  "available"
    t.boolean  "has_car"
    t.string   "will_travel",               limit: 255
    t.string   "aired_on",                  limit: 255
    t.string   "im_service",                limit: 255
    t.string   "role",                      limit: 255
    t.integer  "merged_into_user_id",       limit: 4
    t.string   "time_zone",                 limit: 255
    t.string   "ftp_password",              limit: 255
    t.integer  "daily_message_quota",       limit: 4
    t.string   "category",                  limit: 255
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.integer "browsable_id",   limit: 4
    t.string  "browsable_type", limit: 255
    t.string  "url",            limit: 255
  end

  add_index "websites", ["browsable_id", "browsable_type"], name: "websites_browsable_fk", using: :btree

end
