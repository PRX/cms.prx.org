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

ActiveRecord::Schema.define(version: 20180926154742) do

  create_table "account_applications", force: :cascade do |t|
    t.integer  "account_id",            limit: 4
    t.integer  "client_application_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_applications", ["account_id", "client_application_id"], name: "index_account_applications_uniq", unique: true, using: :btree

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
  add_index "account_images", ["parent_id"], name: "parent_id_idx", using: :btree
  add_index "account_images", ["updated_at"], name: "index_account_images_on_updated_at", using: :btree

  create_table "account_memberships", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "size_limit",     limit: 4
    t.string   "payment_status", limit: 255
    t.string   "payment_type",   limit: 255
    t.integer  "price_paid",     limit: 4
    t.integer  "account_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",          limit: 65535
  end

  add_index "account_memberships", ["account_id", "start_date", "end_date"], name: "current_membership_idx", using: :btree
  add_index "account_memberships", ["account_id"], name: "account_id_idx", using: :btree

  create_table "account_message_types", force: :cascade do |t|
    t.integer  "account_id",         limit: 4
    t.string   "message_type",       limit: 255
    t.text     "user_recipients",    limit: 65535
    t.text     "email_recipients",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "default_recipients", limit: 65535
  end

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
    t.string   "short_name",                       limit: 255
    t.string   "delivery_ftp_user",                limit: 255
  end

  add_index "accounts", ["api_key"], name: "index_accounts_on_api_key", using: :btree
  add_index "accounts", ["contact_id"], name: "accounts_contact_id_fk", using: :btree
  add_index "accounts", ["deleted_at"], name: "deleted_at_idx", using: :btree
  add_index "accounts", ["opener_id"], name: "accounts_opener_id_fk", using: :btree
  add_index "accounts", ["outside_purchaser_at"], name: "outside_purchaser_at_idx", using: :btree
  add_index "accounts", ["path"], name: "path_idx", using: :btree
  add_index "accounts", ["status"], name: "status_idx", using: :btree

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
  add_index "addresses", ["updated_at"], name: "index_addresses_on_updated_at", using: :btree

  create_table "affiliations", force: :cascade do |t|
    t.integer "affiliable_id",   limit: 4
    t.string  "affiliable_type", limit: 255
    t.string  "name",            limit: 255
  end

  create_table "alerts", force: :cascade do |t|
    t.string   "type",         limit: 255
    t.integer  "account_id",   limit: 4
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "alerted_id",   limit: 4
    t.string   "alerted_type", limit: 255
    t.string   "query_key",    limit: 255,   default: "", null: false
    t.text     "options",      limit: 65535
    t.string   "resolution",   limit: 255
  end

  add_index "alerts", ["account_id"], name: "index_alerts_on_account_id", using: :btree
  add_index "alerts", ["alerted_id", "alerted_type"], name: "index_alerts_on_alerted_id_and_alerted_type", using: :btree
  add_index "alerts", ["query_key"], name: "index_alerts_on_key", using: :btree

  create_table "audio_file_deliveries", force: :cascade do |t|
    t.string   "status",         limit: 255
    t.integer  "job_id",         limit: 4
    t.integer  "audio_file_id",  limit: 4
    t.integer  "delivery_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cart_number",    limit: 255
    t.string   "destination",    limit: 255
    t.integer  "segment_number", limit: 4
  end

  add_index "audio_file_deliveries", ["delivery_id"], name: "index_audio_file_deliveries_on_delivery_id", using: :btree

  create_table "audio_file_listenings", force: :cascade do |t|
    t.integer  "audio_file_id",  limit: 4,   default: 0,     null: false
    t.boolean  "thirty_seconds",             default: false
    t.integer  "user_id",        limit: 4
    t.string   "cookie",         limit: 255
    t.string   "user_agent",     limit: 255
    t.string   "ip_address",     limit: 255
    t.string   "from_page",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audio_file_listenings", ["audio_file_id"], name: "audio_file_id_idx", using: :btree

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
    t.integer  "bit_rate",         limit: 4,                             default: 0,   null: false
    t.decimal  "frequency",                      precision: 5, scale: 2, default: 0.0, null: false
    t.string   "channel_mode",     limit: 255
    t.string   "status",           limit: 255
    t.string   "format",           limit: 255
    t.datetime "deleted_at"
    t.string   "listenable_type",  limit: 255
    t.integer  "listenable_id",    limit: 4
    t.string   "upload_path",      limit: 255
    t.integer  "current_job_id",   limit: 4
    t.text     "status_message",   limit: 65535
  end

  add_index "audio_files", ["account_id", "filename"], name: "index_audio_files_on_account_id_and_filename", using: :btree
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
    t.string   "content_type",   limit: 255
  end

  create_table "audio_versions", force: :cascade do |t|
    t.integer  "piece_id",                  limit: 4
    t.string   "label",                     limit: 255
    t.text     "content_advisory",          limit: 65535
    t.text     "timing_and_cues",           limit: 65535
    t.text     "transcript",                limit: 65535
    t.boolean  "news_hole_break"
    t.boolean  "floating_break"
    t.boolean  "bottom_of_hour_break"
    t.boolean  "twenty_forty_break"
    t.boolean  "promos",                                  default: false, null: false
    t.datetime "deleted_at"
    t.integer  "audio_version_template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "explicit",                  limit: 255
    t.string   "status",                    limit: 255
    t.text     "status_message",            limit: 65535
  end

  add_index "audio_versions", ["piece_id"], name: "audio_versions_piece_id_fk", using: :btree
  add_index "audio_versions", ["updated_at"], name: "index_audio_versions_on_updated_at", using: :btree

  create_table "available_for_tasks", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.integer "user_id", limit: 4
  end

  add_index "available_for_tasks", ["user_id"], name: "available_for_tasks_user_id_fk", using: :btree

  create_table "awards", force: :cascade do |t|
    t.integer "awardable_id",   limit: 4
    t.string  "awardable_type", limit: 255
    t.string  "name",           limit: 255
    t.string  "description",    limit: 255
    t.date    "awarded_on"
  end

  create_table "badges_privileges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_privileges", ["name"], name: "index_badges_privileges_on_name", unique: true, using: :btree
  add_index "badges_privileges", ["name"], name: "name_idx", using: :btree

  create_table "badges_role_privileges", force: :cascade do |t|
    t.integer  "role_id",      limit: 4
    t.integer  "privilege_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_role_privileges", ["role_id", "privilege_id"], name: "index_badges_role_privileges_on_role_id_and_privilege_id", using: :btree

  create_table "badges_roles", force: :cascade do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_roles", ["name"], name: "index_badges_roles_on_name", unique: true, using: :btree

  create_table "badges_user_roles", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "role_id",           limit: 4
    t.integer  "authorizable_id",   limit: 4
    t.string   "authorizable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_user_roles", ["authorizable_type", "authorizable_id"], name: "authorizable_idx", using: :btree
  add_index "badges_user_roles", ["user_id", "role_id", "authorizable_type", "authorizable_id"], name: "user_role_authorize", using: :btree
  add_index "badges_user_roles", ["user_id"], name: "index_badges_user_roles_on_user_id", using: :btree

  create_table "blacklists", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklists", ["domain"], name: "index_blacklists_on_domain", unique: true, using: :btree

  create_table "carriages", force: :cascade do |t|
    t.integer  "purchase_id", limit: 4
    t.text     "comments",    limit: 65535
    t.datetime "aired_at"
    t.string   "air_time",    limit: 255
    t.string   "medium",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carriages", ["purchase_id"], name: "purchase_id_idx", using: :btree

  create_table "cart_number_sequences", force: :cascade do |t|
    t.integer  "numbered_id",   limit: 4
    t.string   "numbered_type", limit: 255
    t.integer  "start_number",  limit: 4
    t.integer  "end_number",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_applications", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "url",           limit: 255
    t.string   "support_url",   limit: 255
    t.string   "callback_url",  limit: 255
    t.string   "key",           limit: 40
    t.string   "secret",        limit: 40
    t.integer  "user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url",     limit: 255
    t.string   "description",   limit: 255
    t.string   "template_name", limit: 255
    t.boolean  "auto_grant",                default: false
  end

  add_index "client_applications", ["key"], name: "index_client_applications_on_key", unique: true, using: :btree
  add_index "client_applications", ["name"], name: "client_applications_unique_name_idx", unique: true, using: :btree

  create_table "cms_say_when_job_executions", force: :cascade do |t|
    t.integer  "job_id",   limit: 4
    t.string   "status",   limit: 255
    t.text     "result",   limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
  end

  add_index "cms_say_when_job_executions", ["job_id"], name: "index_cms_say_when_job_executions_on_job_id", using: :btree

  create_table "cms_say_when_jobs", force: :cascade do |t|
    t.string   "group",            limit: 255
    t.string   "name",             limit: 255
    t.string   "status",           limit: 255
    t.string   "trigger_strategy", limit: 255
    t.text     "trigger_options",  limit: 65535
    t.datetime "last_fire_at"
    t.datetime "next_fire_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "job_class",        limit: 255
    t.string   "job_method",       limit: 255
    t.text     "data",             limit: 65535
    t.string   "scheduled_type",   limit: 255
    t.integer  "scheduled_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_say_when_jobs", ["next_fire_at", "status"], name: "index_cms_say_when_jobs_on_next_fire_at_and_status", using: :btree
  add_index "cms_say_when_jobs", ["scheduled_type", "scheduled_id"], name: "index_cms_say_when_jobs_on_scheduled_type_and_scheduled_id", using: :btree

  create_table "comatose_files", force: :cascade do |t|
    t.integer "parent_id",    limit: 4
    t.string  "content_type", limit: 255
    t.string  "filename",     limit: 255
    t.string  "thumbnail",    limit: 255
    t.integer "size",         limit: 4
    t.integer "width",        limit: 4
    t.integer "height",       limit: 4
    t.float   "aspect_ratio", limit: 24
  end

  create_table "comatose_page_files", force: :cascade do |t|
    t.integer "page_id",            limit: 4
    t.integer "file_attachment_id", limit: 4
  end

  create_table "comatose_page_versions", force: :cascade do |t|
    t.integer  "comatose_page_id", limit: 4
    t.integer  "version",          limit: 4
    t.integer  "parent_id",        limit: 8
    t.text     "full_path",        limit: 65535
    t.string   "title",            limit: 255
    t.string   "slug",             limit: 255
    t.string   "keywords",         limit: 255
    t.text     "body",             limit: 16777215
    t.string   "filter_type",      limit: 25,       default: "Textile"
    t.string   "author",           limit: 255
    t.integer  "position",         limit: 8,        default: 0
    t.datetime "updated_on"
    t.datetime "created_on"
    t.string   "status",           limit: 20
    t.datetime "published_on"
  end

  add_index "comatose_page_versions", ["comatose_page_id", "version"], name: "comatose_page_id_version_idx", using: :btree
  add_index "comatose_page_versions", ["comatose_page_id"], name: "comatose_page_id_idx", using: :btree
  add_index "comatose_page_versions", ["version"], name: "version_idx", using: :btree

  create_table "comatose_pages", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.text     "full_path",    limit: 65535
    t.string   "title",        limit: 255
    t.string   "slug",         limit: 255
    t.string   "keywords",     limit: 255
    t.text     "body",         limit: 16777215
    t.string   "filter_type",  limit: 25,       default: "Textile"
    t.string   "author",       limit: 255
    t.integer  "position",     limit: 4,        default: 0
    t.integer  "version",      limit: 4
    t.datetime "updated_on"
    t.datetime "created_on"
    t.string   "status",       limit: 40,       default: "draft"
    t.datetime "published_on"
  end

  create_table "comment_ratings", force: :cascade do |t|
    t.integer  "comment_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "helpful",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "commentable_type", limit: 255
    t.integer  "commentable_id",   limit: 4
    t.string   "title",            limit: 255
    t.text     "body",             limit: 65535
    t.integer  "user_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
  add_index "comments", ["deleted_at"], name: "deleted_at_idx", using: :btree
  add_index "comments", ["user_id"], name: "user_id_idx", using: :btree

  create_table "contact_associations", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "contact_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
  end

  create_table "date_peg_instances", force: :cascade do |t|
    t.integer  "date_peg_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "date_pegs", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
    t.integer "playlist_id", limit: 4
    t.string  "slug",        limit: 255
  end

  create_table "default_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.integer  "position",     limit: 4
    t.string   "filename",     limit: 255
    t.string   "content_type", limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.string   "thumbnail",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.string   "tone",         limit: 255
    t.string   "credit_url",   limit: 255
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer  "subscription_id",   limit: 4
    t.integer  "piece_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_id",       limit: 4
    t.string   "status",            limit: 255
    t.string   "transport_method",  limit: 255
    t.string   "filename_format",   limit: 255
    t.string   "audio_type",        limit: 255
    t.integer  "cart_number_start", limit: 4
    t.integer  "end_air_days",      limit: 4
    t.integer  "audio_version_id",  limit: 4
    t.boolean  "deliver_promos"
    t.integer  "episode_number",    limit: 4
  end

  add_index "deliveries", ["subscription_id", "episode_number"], name: "index_deliveries_on_subscription_id_and_episode_number", using: :btree

  create_table "delivery_logs", force: :cascade do |t|
    t.integer  "delivery_id",            limit: 4
    t.string   "status",                 limit: 255
    t.string   "message",                limit: 255
    t.text     "result",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "audio_file_delivery_id", limit: 4
    t.datetime "logged_at"
  end

  add_index "delivery_logs", ["audio_file_delivery_id", "logged_at", "status"], name: "delivery_logs_audio_logged_status_index", using: :btree
  add_index "delivery_logs", ["delivery_id", "audio_file_delivery_id", "logged_at"], name: "delivery_delivery_logs", using: :btree

  create_table "discounts", force: :cascade do |t|
    t.integer "discountable_id",   limit: 4
    t.string  "discountable_type", limit: 255
    t.float   "amount",            limit: 24
    t.string  "type",              limit: 255
    t.text    "note",              limit: 65535
    t.date    "expires_at"
    t.date    "starts_at"
  end

  create_table "distribution_templates", force: :cascade do |t|
    t.integer  "distribution_id",           limit: 4
    t.integer  "audio_version_template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distribution_templates", ["distribution_id", "audio_version_template_id"], name: "index_distribution_templates", unique: true, using: :btree

  create_table "distributions", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.string   "distributable_type", limit: 255
    t.integer  "distributable_id",   limit: 4
    t.string   "url",                limit: 255
    t.string   "guid",               limit: 255
    t.text     "properties",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distributions", ["distributable_type", "distributable_id"], name: "index_distributions_on_distributable_type_and_distributable_id", using: :btree

  create_table "educational_experiences", force: :cascade do |t|
    t.string  "degree",       limit: 255
    t.string  "school",       limit: 255
    t.integer "user_id",      limit: 4
    t.date    "graduated_on"
  end

  add_index "educational_experiences", ["user_id"], name: "educational_experiences_user_id_fk", using: :btree

  create_table "episode_imports", force: :cascade do |t|
    t.integer  "podcast_import_id",  limit: 4
    t.integer  "piece_id",           limit: 4
    t.string   "guid",               limit: 255
    t.text     "entry",              limit: 65535
    t.text     "audio",              limit: 65535
    t.string   "status",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_duplicate_guid",               default: false
  end

  add_index "episode_imports", ["has_duplicate_guid"], name: "index_episode_imports_on_has_duplicate_guid", using: :btree
  add_index "episode_imports", ["podcast_import_id"], name: "index_episode_imports_on_podcast_import_id", using: :btree

  create_table "equipment", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.integer "user_id", limit: 4
  end

  add_index "equipment", ["user_id"], name: "equipment_user_id_fk", using: :btree

  create_table "feed_items", force: :cascade do |t|
    t.integer  "actor_id",           limit: 4
    t.string   "actor_type",         limit: 25
    t.string   "action",             limit: 50
    t.integer  "action_object_id",   limit: 4
    t.string   "action_object_type", limit: 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message",            limit: 25
    t.string   "kind",               limit: 25
    t.boolean  "is_public",                      default: true
    t.string   "from_url",           limit: 255
  end

  add_index "feed_items", ["action_object_type", "action_object_id", "action", "created_at"], name: "by_activity_graphs", using: :btree
  add_index "feed_items", ["actor_id", "actor_type"], name: "actor_idx", using: :btree
  add_index "feed_items", ["is_public"], name: "by_is_public", using: :btree

  create_table "feed_items_archive", force: :cascade do |t|
    t.integer  "actor_id",           limit: 4
    t.string   "actor_type",         limit: 25
    t.string   "action",             limit: 50
    t.integer  "action_object_id",   limit: 4
    t.string   "action_object_type", limit: 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message",            limit: 25
    t.string   "kind",               limit: 25
    t.boolean  "is_public",                      default: true
    t.string   "from_url",           limit: 255
  end

  add_index "feed_items_archive", ["action_object_type", "action_object_id", "action", "created_at"], name: "by_activity_graphs", using: :btree
  add_index "feed_items_archive", ["actor_id", "actor_type"], name: "actor_idx", using: :btree
  add_index "feed_items_archive", ["is_public"], name: "by_is_public", using: :btree

  create_table "financial_transactions", force: :cascade do |t|
    t.string   "paypal_transaction_id", limit: 255
    t.string   "paypal_type",           limit: 255
    t.string   "status",                limit: 255
    t.datetime "received_at"
    t.string   "gross",                 limit: 255
    t.string   "fee",                   limit: 255
    t.string   "currency",              limit: 255
    t.integer  "account_membership_id", limit: 4
    t.string   "account",               limit: 255
    t.string   "invoice",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flags", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "flaggable_id",   limit: 4
    t.string   "flaggable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reason",         limit: 255
  end

  add_index "flags", ["flaggable_id", "flaggable_type"], name: "flaggable_idx", using: :btree

  create_table "formats", force: :cascade do |t|
    t.integer "piece_id", limit: 4
    t.string  "name",     limit: 255
  end

  add_index "formats", ["name"], name: "name_idx", using: :btree
  add_index "formats", ["piece_id"], name: "formats_piece_id_fk", using: :btree

  create_table "ftp_addresses", force: :cascade do |t|
    t.integer "ftpable_id",   limit: 4
    t.string  "ftpable_type", limit: 255
    t.string  "host",         limit: 255
    t.string  "port",         limit: 255
    t.string  "user",         limit: 255
    t.string  "password",     limit: 255
    t.string  "directory",    limit: 255
    t.text    "options",      limit: 65535
  end

  create_table "geo_data", force: :cascade do |t|
    t.string "zip_code",    limit: 255
    t.string "zip_type",    limit: 255
    t.string "city",        limit: 255
    t.string "city_type",   limit: 255
    t.string "county",      limit: 255
    t.string "county_fips", limit: 255
    t.string "state",       limit: 255
    t.string "state_abbr",  limit: 255
    t.string "state_fips",  limit: 255
    t.string "msa_code",    limit: 255
    t.string "area_code",   limit: 255
    t.string "time_zone",   limit: 255
    t.string "utc",         limit: 255
    t.string "dst",         limit: 255
    t.float  "latitude",    limit: 24
    t.float  "longitude",   limit: 24
  end

  add_index "geo_data", ["area_code"], name: "area_code_idx", using: :btree
  add_index "geo_data", ["latitude"], name: "latitude_idx", using: :btree
  add_index "geo_data", ["longitude"], name: "longitude_idx", using: :btree
  add_index "geo_data", ["time_zone"], name: "time_zone_idx", using: :btree
  add_index "geo_data", ["zip_code"], name: "zip_code_idx", using: :btree

  create_table "geocodes", force: :cascade do |t|
    t.decimal "latitude",                precision: 15, scale: 12
    t.decimal "longitude",               precision: 15, scale: 12
    t.string  "query",       limit: 255
    t.string  "street",      limit: 255
    t.string  "locality",    limit: 255
    t.string  "region",      limit: 255
    t.string  "postal_code", limit: 255
    t.string  "country",     limit: 255
    t.boolean "approximate"
  end

  add_index "geocodes", ["latitude"], name: "geocodes_latitude_index", using: :btree
  add_index "geocodes", ["longitude"], name: "geocodes_longitude_index", using: :btree
  add_index "geocodes", ["query"], name: "geocodes_query_index", unique: true, using: :btree

  create_table "geocodings", force: :cascade do |t|
    t.integer "geocodable_id",   limit: 4
    t.integer "geocode_id",      limit: 4
    t.string  "geocodable_type", limit: 255
  end

  add_index "geocodings", ["geocodable_id"], name: "geocodings_geocodable_id_index", using: :btree
  add_index "geocodings", ["geocodable_type"], name: "geocodings_geocodable_type_index", using: :btree
  add_index "geocodings", ["geocode_id"], name: "geocodings_geocode_id_index", using: :btree

  create_table "greylistings", force: :cascade do |t|
    t.integer  "piece_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "greylistings", ["piece_id"], name: "piece_id_idx", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "provider",     limit: 255
    t.string   "accesstoken",  limit: 255
    t.string   "uid",          limit: 255
    t.string   "email",        limit: 255
    t.string   "image_url",    limit: 255
    t.string   "secrettoken",  limit: 255
    t.string   "refreshtoken", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.integer "user_id", limit: 4
  end

  add_index "languages", ["user_id"], name: "languages_user_id_fk", using: :btree

  create_table "license_versions", force: :cascade do |t|
    t.integer  "license_id",       limit: 4
    t.integer  "version",          limit: 4
    t.integer  "piece_id",         limit: 8
    t.string   "website_usage",    limit: 255
    t.string   "allow_edit",       limit: 255
    t.text     "additional_terms", limit: 65535
    t.integer  "version_user_id",  limit: 8
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
  end

  add_index "license_versions", ["license_id", "version"], name: "index_license_versions_on_license_id_and_version", unique: true, using: :btree

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
  add_index "licenses", ["updated_at"], name: "index_licenses_on_updated_at", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "request",    limit: 65535
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       limit: 255
  end

  add_index "memberships", ["account_id"], name: "memberships_account_id_fk", using: :btree
  add_index "memberships", ["updated_at"], name: "index_memberships_on_updated_at", using: :btree
  add_index "memberships", ["user_id"], name: "memberships_user_id_fk", using: :btree

  create_table "memberships_old", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "request",    limit: 65535
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       limit: 255
  end

  add_index "memberships_old", ["account_id"], name: "memberships_account_id_fk", using: :btree
  add_index "memberships_old", ["updated_at"], name: "index_memberships_on_updated_at", using: :btree
  add_index "memberships_old", ["user_id"], name: "memberships_user_id_fk", using: :btree

  create_table "message_receptions", force: :cascade do |t|
    t.integer  "message_id",           limit: 4
    t.integer  "recipient_id",         limit: 4
    t.boolean  "read",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_recipient",           default: false
  end

  add_index "message_receptions", ["message_id"], name: "index_message_receptions_on_message_id", using: :btree
  add_index "message_receptions", ["recipient_id", "deleted_by_recipient"], name: "by_recipient", using: :btree
  add_index "message_receptions", ["recipient_id", "message_id", "deleted_by_recipient"], name: "message_receptions_inbox_index", using: :btree

  create_table "message_recipient_finders", force: :cascade do |t|
    t.text     "finder_expression", limit: 65535
    t.string   "label",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",                   limit: 4
    t.string   "subject",                     limit: 255
    t.text     "body",                        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",                   limit: 4
    t.boolean  "deleted_by_sender",                         default: false
    t.string   "type",                        limit: 255
    t.integer  "priority",                    limit: 4
    t.integer  "message_recipient_finder_id", limit: 4
  end

  add_index "messages", ["parent_id"], name: "index_messages_on_parent_id", using: :btree
  add_index "messages", ["sender_id", "deleted_by_sender"], name: "index_messages_on_sender_id_and_deleted_by_sender", using: :btree

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
  add_index "musical_works", ["updated_at"], name: "index_musical_works_on_updated_at", using: :btree

  create_table "network_files", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "network_memberships", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "network_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "network_pieces", force: :cascade do |t|
    t.integer  "piece_id",             limit: 4
    t.integer  "network_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point_level",          limit: 4
    t.integer  "custom_points",        limit: 4
    t.datetime "has_custom_points_at"
  end

  add_index "network_pieces", ["network_id"], name: "network_pieces_network_id_fk", using: :btree
  add_index "network_pieces", ["piece_id"], name: "network_pieces_piece_id_fk", using: :btree

  create_table "network_requests", force: :cascade do |t|
    t.integer  "account_id",            limit: 4
    t.integer  "user_id",               limit: 4
    t.string   "name",                  limit: 255
    t.string   "description",           limit: 255
    t.string   "pricing_strategy",      limit: 255,   default: "",        null: false
    t.string   "publishing_strategy",   limit: 255,   default: "",        null: false
    t.string   "notification_strategy", limit: 255,   default: "",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                 limit: 255,   default: "pending"
    t.text     "note",                  limit: 65535
    t.datetime "reviewed_at"
    t.string   "path",                  limit: 255
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

  create_table "numeric_sequences", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "last_number", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "numeric_sequences", ["name"], name: "index_numeric_sequences_on_name", unique: true, using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id",      limit: 4
    t.integer  "application_id",         limit: 4
    t.string   "token",                  limit: 255,              null: false
    t.string   "refresh_token",          limit: 255
    t.integer  "expires_in",             limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                                      null: false
    t.string   "scopes",                 limit: 255
    t.string   "previous_refresh_token", limit: 255, default: "", null: false
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.string   "scopes",       limit: 255,   default: "", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "oauth_nonces", force: :cascade do |t|
    t.string   "nonce",      limit: 255
    t.integer  "timestamp",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true, using: :btree

  create_table "oauth_tokens", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "type",                  limit: 20
    t.integer  "client_application_id", limit: 4
    t.string   "token",                 limit: 40
    t.string   "secret",                limit: 40
    t.string   "callback_url",          limit: 255
    t.string   "verifier",              limit: 20
    t.string   "scope",                 limit: 255
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], name: "index_oauth_tokens_on_token", unique: true, using: :btree

  create_table "open_id_associations", force: :cascade do |t|
    t.binary  "server_url", limit: 65535, null: false
    t.string  "handle",     limit: 255,   null: false
    t.binary  "secret",     limit: 65535, null: false
    t.integer "issued",     limit: 4,     null: false
    t.integer "lifetime",   limit: 4,     null: false
    t.string  "assoc_type", limit: 255,   null: false
  end

  create_table "open_id_nonces", force: :cascade do |t|
    t.string  "server_url", limit: 255, null: false
    t.integer "timestamp",  limit: 4,   null: false
    t.string  "salt",       limit: 255, null: false
  end

  create_table "outside_purchaser_info_versions", force: :cascade do |t|
    t.integer  "outside_purchaser_info_id", limit: 4
    t.integer  "version",                   limit: 4
    t.integer  "outside_purchaser_id",      limit: 8
    t.string   "payment_type",              limit: 255
    t.string   "purchaser_type",            limit: 255
    t.decimal  "rate",                                    precision: 9, scale: 2
    t.text     "terms",                     limit: 65535
    t.text     "description",               limit: 65535
    t.text     "payment_terms",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version_user_id",           limit: 8
    t.datetime "deleted_at"
  end

  create_table "outside_purchaser_infos", force: :cascade do |t|
    t.integer  "outside_purchaser_id", limit: 4
    t.string   "payment_type",         limit: 255
    t.string   "purchaser_type",       limit: 255
    t.decimal  "rate",                               precision: 9, scale: 2
    t.text     "terms",                limit: 65535
    t.text     "description",          limit: 65535
    t.text     "payment_terms",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version_user_id",      limit: 4
    t.integer  "version",              limit: 4
    t.datetime "deleted_at"
  end

  add_index "outside_purchaser_infos", ["outside_purchaser_id"], name: "outside_purchaser_infos_outside_purchaser_id_fk", using: :btree

  create_table "outside_purchaser_optins", force: :cascade do |t|
    t.integer  "piece_id",             limit: 4
    t.integer  "outside_purchaser_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outside_purchaser_optins", ["outside_purchaser_id"], name: "outside_purchaser_pieces_outside_purchaser_id_fk", using: :btree
  add_index "outside_purchaser_optins", ["piece_id"], name: "outside_purchaser_pieces_piece_id_fk", using: :btree

  create_table "outside_purchaser_preferences", force: :cascade do |t|
    t.integer  "account_id",           limit: 4
    t.integer  "outside_purchaser_id", limit: 4
    t.string   "allow",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outside_purchaser_preferences", ["account_id"], name: "account_outside_purchaser_options_account_id_fk", using: :btree
  add_index "outside_purchaser_preferences", ["outside_purchaser_id"], name: "account_outside_purchaser_options_outside_purchaser_id_fk", using: :btree

  create_table "piece_date_pegs", force: :cascade do |t|
    t.integer "piece_id",    limit: 4
    t.integer "date_peg_id", limit: 4
    t.string  "name",        limit: 255
    t.integer "year",        limit: 4
    t.integer "month",       limit: 4
    t.integer "day",         limit: 4
  end

  add_index "piece_date_pegs", ["date_peg_id"], name: "piece_date_pegs_date_peg_id_fk", using: :btree
  add_index "piece_date_pegs", ["piece_id"], name: "piece_date_pegs_piece_id_fk", using: :btree

  create_table "piece_files", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "piece_id",     limit: 4
    t.integer  "size",         limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "label",        limit: 255
  end

  add_index "piece_files", ["piece_id"], name: "piece_files_piece_id_fk", using: :btree

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

  add_index "piece_images", ["parent_id"], name: "parent_id_idx", using: :btree
  add_index "piece_images", ["piece_id"], name: "piece_images_piece_id_fk", using: :btree
  add_index "piece_images", ["position"], name: "position_idx", using: :btree

  create_table "pieces", force: :cascade do |t|
    t.integer  "position",                limit: 4
    t.integer  "account_id",              limit: 4
    t.integer  "creator_id",              limit: 4
    t.integer  "series_id",               limit: 4
    t.string   "title",                   limit: 255
    t.text     "short_description",       limit: 16777215
    t.text     "description",             limit: 16777215
    t.date     "produced_on"
    t.string   "language",                limit: 255
    t.string   "related_website",         limit: 255
    t.text     "credits",                 limit: 16777215
    t.text     "broadcast_history",       limit: 16777215
    t.text     "intro",                   limit: 16777215
    t.text     "outro",                   limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",                  limit: 4
    t.integer  "point_level",             limit: 4
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.text     "legacy_musical_works",    limit: 16777215
    t.integer  "episode_number",          limit: 4
    t.datetime "network_only_at"
    t.integer  "image_id",                limit: 4
    t.datetime "featured_at"
    t.boolean  "allow_comments",                           default: true
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
    t.string   "app_version",             limit: 255,      default: "v3", null: false
    t.string   "marketplace_subtitle",    limit: 255
    t.text     "marketplace_information", limit: 16777215
    t.integer  "network_id",              limit: 4
    t.datetime "released_at"
    t.string   "status",                  limit: 255
    t.text     "status_message",          limit: 16777215
    t.string   "season_identifier",       limit: 255
    t.string   "clean_title",             limit: 255
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

  create_table "playlist_images", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "size",         limit: 4
    t.integer  "width",        limit: 4
    t.integer  "height",       limit: 4
    t.float    "aspect_ratio", limit: 24
    t.integer  "playlist_id",  limit: 4
    t.string   "caption",      limit: 255
    t.string   "credit",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_path",  limit: 255
    t.string   "status",       limit: 255
  end

  create_table "playlist_sections", force: :cascade do |t|
    t.integer  "playlist_id", limit: 4
    t.string   "title",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",    limit: 4
    t.text     "comment",     limit: 65535
  end

  add_index "playlist_sections", ["playlist_id"], name: "playlist_idx", using: :btree
  add_index "playlist_sections", ["position"], name: "position_idx", using: :btree

  create_table "playlisting_images", force: :cascade do |t|
    t.integer  "parent_id",      limit: 4
    t.string   "content_type",   limit: 255
    t.string   "filename",       limit: 255
    t.string   "thumbnail",      limit: 255
    t.integer  "size",           limit: 4
    t.integer  "width",          limit: 4
    t.integer  "height",         limit: 4
    t.float    "aspect_ratio",   limit: 24
    t.integer  "playlisting_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "caption",        limit: 255
    t.string   "credit",         limit: 255
    t.string   "upload_path",    limit: 255
    t.string   "status",         limit: 255
  end

  add_index "playlisting_images", ["playlisting_id"], name: "playlisting_images_playlisting_id_fk", using: :btree

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

  add_index "playlistings", ["playlist_section_id"], name: "playlist_section_id_idx", using: :btree
  add_index "playlistings", ["playlistable_id", "playlistable_type"], name: "playlistable_idx", using: :btree

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

  add_index "playlists", ["account_id"], name: "account_idx", using: :btree
  add_index "playlists", ["deleted_at"], name: "deleted_at_idx", using: :btree
  add_index "playlists", ["published_at"], name: "published_at_idx", using: :btree
  add_index "playlists", ["type"], name: "type_idx", using: :btree

  create_table "podcast_imports", force: :cascade do |t|
    t.integer  "user_id",                 limit: 4
    t.integer  "account_id",              limit: 4
    t.integer  "series_id",               limit: 4
    t.string   "url",                     limit: 255
    t.string   "status",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "config",                  limit: 4294967295
    t.integer  "feed_episode_count", limit: 4
  end

  create_table "point_package_versions", force: :cascade do |t|
    t.integer  "point_package_id",      limit: 4
    t.integer  "version",               limit: 4
    t.integer  "account_id",            limit: 8
    t.integer  "seller_id",             limit: 8
    t.integer  "points",                limit: 8
    t.date     "expires_on"
    t.integer  "total_station_revenue", limit: 8
    t.decimal  "price",                               precision: 9, scale: 2
    t.decimal  "list",                                precision: 9, scale: 2
    t.decimal  "discount",                            precision: 9, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",                 limit: 65535
    t.datetime "deleted_at"
    t.decimal  "prx_cut",                             precision: 9, scale: 2
    t.decimal  "royalty_cut",                         precision: 9, scale: 2
    t.string   "package_type",          limit: 255
    t.date     "ends_on"
    t.integer  "prx_percentage",        limit: 8
    t.integer  "subscription_id",       limit: 8
    t.integer  "points_purchased",      limit: 8
    t.integer  "version_user_id",       limit: 8
    t.decimal  "witholding",                          precision: 9, scale: 2
    t.boolean  "locked"
  end

  create_table "point_packages", force: :cascade do |t|
    t.integer  "account_id",            limit: 4
    t.integer  "seller_id",             limit: 4
    t.integer  "points",                limit: 4
    t.date     "expires_on"
    t.integer  "total_station_revenue", limit: 4
    t.decimal  "price",                               precision: 9, scale: 2
    t.decimal  "list",                                precision: 9, scale: 2
    t.decimal  "discount",                            precision: 9, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",                 limit: 65535
    t.datetime "deleted_at"
    t.decimal  "prx_cut",                             precision: 9, scale: 2
    t.decimal  "royalty_cut",                         precision: 9, scale: 2
    t.string   "package_type",          limit: 255
    t.date     "ends_on"
    t.integer  "prx_percentage",        limit: 4
    t.integer  "subscription_id",       limit: 4
    t.integer  "points_purchased",      limit: 4
    t.integer  "version_user_id",       limit: 4
    t.integer  "version",               limit: 4
    t.decimal  "witholding",                          precision: 9, scale: 2
    t.boolean  "locked",                                                      default: true
  end

  add_index "point_packages", ["account_id"], name: "point_packages_account_id_fk", using: :btree
  add_index "point_packages", ["seller_id"], name: "point_packages_seller_id_fk", using: :btree

  create_table "pricing_tiers", force: :cascade do |t|
    t.integer  "minimum_tsr", limit: 4
    t.integer  "maximum_tsr", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pricing_tiers_seasons", id: false, force: :cascade do |t|
    t.integer "pricing_tier_id", limit: 4
    t.integer "season_id",       limit: 4
  end

  create_table "privacy_settings", force: :cascade do |t|
    t.integer  "protect_id",   limit: 4
    t.string   "protect_type", limit: 255
    t.string   "level",        limit: 255
    t.string   "information",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "privacy_settings", ["information"], name: "information_idx", using: :btree
  add_index "privacy_settings", ["protect_id", "protect_type"], name: "protect_idx", using: :btree

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
  add_index "producers", ["updated_at"], name: "index_producers_on_updated_at", using: :btree
  add_index "producers", ["user_id"], name: "producers_user_id_fk", using: :btree

  create_table "published_feed_items", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "feed_item_id", limit: 4
    t.boolean  "is_visible",             default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_allocations", force: :cascade do |t|
    t.integer  "purchase_id",      limit: 4
    t.integer  "point_package_id", limit: 4
    t.decimal  "quantity",                   precision: 9, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "purchases", ["purchased_at"], name: "purchased_at_idx", using: :btree
  add_index "purchases", ["purchased_id", "purchased_type"], name: "purchased_idx", using: :btree
  add_index "purchases", ["purchaser_account_id"], name: "purchases_purchaser_account_id_fk", using: :btree
  add_index "purchases", ["purchaser_id"], name: "purchases_purchaser_id_fk", using: :btree
  add_index "purchases", ["seller_account_id"], name: "purchases_seller_account_id_fk", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value",        limit: 4,   default: 0,  null: false
    t.integer  "ratable_id",   limit: 4,   default: 0,  null: false
    t.string   "ratable_type", limit: 255, default: "", null: false
  end

  add_index "ratings", ["ratable_type", "ratable_id"], name: "index_ratings_on_ratable_type_and_ratable_id", using: :btree

  create_table "say_when_job_executions", force: :cascade do |t|
    t.integer  "job_id",   limit: 4
    t.string   "status",   limit: 255
    t.text     "result",   limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
  end

  add_index "say_when_job_executions", ["job_id"], name: "index_say_when_job_executions_on_job_id", using: :btree

  create_table "say_when_jobs", force: :cascade do |t|
    t.string   "group",            limit: 255
    t.string   "name",             limit: 255
    t.string   "status",           limit: 255
    t.string   "trigger_strategy", limit: 255
    t.text     "trigger_options",  limit: 65535
    t.datetime "last_fire_at"
    t.datetime "next_fire_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "job_class",        limit: 255
    t.string   "job_method",       limit: 255
    t.text     "data",             limit: 65535
    t.string   "scheduled_type",   limit: 255
    t.integer  "scheduled_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "say_when_jobs", ["next_fire_at"], name: "index_say_when_jobs_on_next_fire_at", using: :btree
  add_index "say_when_jobs", ["status"], name: "index_say_when_jobs_on_status", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.integer  "series_id",  limit: 4
    t.integer  "day",        limit: 4
    t.integer  "hour",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["series_id"], name: "index_schedules_on_series_id", using: :btree

  create_table "seasons_series", id: false, force: :cascade do |t|
    t.integer "season_id", limit: 4
    t.integer "series_id", limit: 4
  end

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

  create_table "series_files", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "series_id",    limit: 4
    t.integer  "size",         limit: 4
    t.string   "content_type", limit: 255
    t.string   "filename",     limit: 255
    t.string   "label",        limit: 255
  end

  add_index "series_files", ["series_id"], name: "series_files_series_id_fk", using: :btree

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

  create_table "site_message_receptions", force: :cascade do |t|
    t.integer  "site_message_id", limit: 4
    t.integer  "recipient_id",    limit: 4
    t.datetime "read_at"
    t.datetime "dismissed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_messages", force: :cascade do |t|
    t.integer  "sender_id",    limit: 4
    t.string   "body",         limit: 255
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.integer "user_id", limit: 4
  end

  add_index "skills", ["user_id"], name: "skills_user_id_fk", using: :btree

  create_table "station_accounts", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "station_formats", force: :cascade do |t|
    t.string  "format",     limit: 255
    t.integer "station_id", limit: 4
  end

  add_index "station_formats", ["station_id"], name: "station_formats_station_id_fk", using: :btree

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

  create_table "subscription_invoices", force: :cascade do |t|
    t.integer "subscription_id", limit: 4
    t.date    "date"
    t.string  "type",            limit: 255
  end

  create_table "subscription_line_items", force: :cascade do |t|
    t.string  "description",             limit: 255
    t.integer "subscription_invoice_id", limit: 4
    t.integer "discount_id",             limit: 4
  end

  create_table "subscription_prices", force: :cascade do |t|
    t.integer  "series_id",       limit: 4
    t.integer  "pricing_tier_id", limit: 4
    t.integer  "value",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "season_id",       limit: 4
  end

  create_table "subscription_seasons", force: :cascade do |t|
    t.string   "label",            limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "pricing_due_date"
    t.boolean  "nonstandard"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "series_id",                 limit: 4
    t.integer  "account_id",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "end_air_days",              limit: 4
    t.string   "delivery_audio_type",       limit: 255
    t.datetime "file_delivery_at"
    t.integer  "cart_number_start",         limit: 4
    t.integer  "cart_number_factor",        limit: 4
    t.string   "delivery_filename_format",  limit: 255
    t.string   "delivery_transport_method", limit: 255
    t.integer  "audio_version_template_id", limit: 4
    t.string   "producer_app_id",           limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "approved_by_subscriber"
    t.boolean  "approved_by_producer"
    t.datetime "agreed_to_terms_at"
    t.integer  "susbscriber_id",            limit: 4
    t.datetime "approved_at"
    t.integer  "days_early",                limit: 4
    t.integer  "days_late",                 limit: 4
    t.string   "billing_name",              limit: 255
    t.string   "billing_phone",             limit: 255
    t.string   "billing_email",             limit: 255
    t.integer  "promos_cart_number_start",  limit: 4
    t.integer  "promos_cart_number_factor", limit: 4
    t.string   "billing_frequency",         limit: 255
    t.integer  "tsr",                       limit: 4
    t.text     "notes",                     limit: 65535
    t.integer  "active_deliveries_max",     limit: 4,     default: 0
    t.integer  "start_air_days_early",      limit: 4,     default: 0
    t.boolean  "no_pad_byte",                             default: false
    t.text     "selected_hours",            limit: 65535
  end

  add_index "subscriptions", ["account_id"], name: "index_subscriptions_on_account_id", using: :btree
  add_index "subscriptions", ["series_id"], name: "index_subscriptions_on_series_id", using: :btree

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

  add_index "tones", ["name"], name: "name_idx", using: :btree
  add_index "tones", ["piece_id"], name: "tones_piece_id_fk", using: :btree

  create_table "topics", force: :cascade do |t|
    t.integer "piece_id", limit: 4
    t.string  "name",     limit: 255
  end

  add_index "topics", ["name"], name: "name_idx", using: :btree
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

  add_index "user_images", ["updated_at"], name: "index_user_images_on_updated_at", using: :btree
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
    t.string   "time_zone",                 limit: 255
    t.integer  "merged_into_user_id",       limit: 4
    t.string   "ftp_password",              limit: 255
    t.integer  "daily_message_quota",       limit: 4
    t.string   "category",                  limit: 255
    t.datetime "suspended_at"
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree
  add_index "users", ["activation_code"], name: "activation_code_idx", using: :btree
  add_index "users", ["deleted_at"], name: "deleted_at_idx", using: :btree
  add_index "users", ["email"], name: "users_email_idx", using: :btree
  add_index "users", ["login"], name: "login_idx", using: :btree
  add_index "users", ["remember_token"], name: "remember_token_idx", using: :btree
  add_index "users", ["reset_password_token"], name: "users_unique_reset_password_token_idx", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.integer "browsable_id",   limit: 4
    t.string  "browsable_type", limit: 255
    t.string  "url",            limit: 255
  end

  create_table "work_experiences", force: :cascade do |t|
    t.string  "position",    limit: 255
    t.string  "company",     limit: 255
    t.string  "description", limit: 255
    t.boolean "current"
    t.date    "started_on"
    t.date    "ended_on"
    t.integer "user_id",     limit: 4
  end

  add_index "work_experiences", ["user_id"], name: "work_experiences_user_id_fk", using: :btree

  add_foreign_key "educational_experiences", "users", name: "educational_experiences_user_id_fk"
  add_foreign_key "equipment", "users", name: "equipment_user_id_fk"
  add_foreign_key "formats", "pieces", name: "formats_piece_id_fk"
  add_foreign_key "languages", "users", name: "languages_user_id_fk"
  add_foreign_key "licenses", "pieces", name: "licenses_piece_id_fk"
  add_foreign_key "memberships_old", "accounts", name: "memberships_account_id_fk"
  add_foreign_key "memberships_old", "users", name: "memberships_user_id_fk"
  add_foreign_key "network_pieces", "networks", name: "network_pieces_network_id_fk"
  add_foreign_key "network_pieces", "pieces", name: "network_pieces_piece_id_fk"
  add_foreign_key "outside_purchaser_infos", "accounts", column: "outside_purchaser_id", name: "outside_purchaser_infos_outside_purchaser_id_fk"
  add_foreign_key "outside_purchaser_optins", "accounts", column: "outside_purchaser_id", name: "outside_purchaser_pieces_outside_purchaser_id_fk"
  add_foreign_key "outside_purchaser_optins", "pieces", name: "outside_purchaser_pieces_piece_id_fk"
  add_foreign_key "outside_purchaser_preferences", "accounts", column: "outside_purchaser_id", name: "account_outside_purchaser_options_outside_purchaser_id_fk"
  add_foreign_key "outside_purchaser_preferences", "accounts", name: "account_outside_purchaser_options_account_id_fk"
  add_foreign_key "playlisting_images", "playlistings", name: "playlisting_images_playlisting_id_fk"
  add_foreign_key "point_packages", "accounts", name: "point_packages_account_id_fk"
  add_foreign_key "point_packages", "users", column: "seller_id", name: "point_packages_seller_id_fk"
  add_foreign_key "producers", "pieces", name: "producers_piece_id_fk"
  add_foreign_key "producers", "users", name: "producers_user_id_fk"
  add_foreign_key "purchases", "accounts", column: "purchaser_account_id", name: "purchases_purchaser_account_id_fk"
  add_foreign_key "purchases", "accounts", column: "seller_account_id", name: "purchases_seller_account_id_fk"
  add_foreign_key "purchases", "users", column: "purchaser_id", name: "purchases_purchaser_id_fk"
  add_foreign_key "series_files", "series", name: "series_files_series_id_fk"
  add_foreign_key "series_images", "series", name: "series_images_series_id_fk"
  add_foreign_key "skills", "users", name: "skills_user_id_fk"
  add_foreign_key "station_formats", "accounts", column: "station_id", name: "station_formats_station_id_fk"
  add_foreign_key "tones", "pieces", name: "tones_piece_id_fk"
  add_foreign_key "topics", "pieces", name: "topics_piece_id_fk"
  add_foreign_key "user_images", "users", name: "user_images_user_id_fk"
  add_foreign_key "work_experiences", "users", name: "work_experiences_user_id_fk"
end
