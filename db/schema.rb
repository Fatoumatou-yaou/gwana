# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_30_161737) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "content"
    t.bigint "author_id", null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.string "category"
    t.text "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "media_type"
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["category"], name: "index_articles_on_category"
    t.index ["media_type"], name: "index_articles_on_media_type"
    t.index ["published"], name: "index_articles_on_published"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "communes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_communes_on_department_id"
    t.index ["name", "department_id"], name: "index_communes_on_name_and_department_id", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "region_id"], name: "index_departments_on_name_and_region_id", unique: true
    t.index ["region_id"], name: "index_departments_on_region_id"
  end

  create_table "gwana_activities", force: :cascade do |t|
    t.bigint "gwana_id", null: false
    t.string "activity_type"
    t.string "youtube_video_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_gwana_activities_on_activity_type"
    t.index ["gwana_id"], name: "index_gwana_activities_on_gwana_id"
  end

  create_table "gwana_network_requests", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "address"
    t.bigint "commune_id"
    t.string "profession"
    t.text "experiences"
    t.text "formations"
    t.text "bio"
    t.string "linkedin_url"
    t.string "twitter_url"
    t.string "website_url"
    t.integer "status", default: 0, null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commune_id"], name: "index_gwana_network_requests_on_commune_id"
    t.index ["created_at"], name: "index_gwana_network_requests_on_created_at"
    t.index ["email"], name: "index_gwana_network_requests_on_email"
    t.index ["phone"], name: "index_gwana_network_requests_on_phone_unique", unique: true, where: "(phone IS NOT NULL)"
    t.index ["reviewed_by_id"], name: "index_gwana_network_requests_on_reviewed_by_id"
    t.index ["status"], name: "index_gwana_network_requests_on_status"
  end

  create_table "gwana_update_requests", force: :cascade do |t|
    t.bigint "gwana_id", null: false
    t.text "bio"
    t.integer "status", default: 0, null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gwana_id"], name: "index_gwana_update_requests_on_gwana_id"
    t.index ["reviewed_by_id"], name: "index_gwana_update_requests_on_reviewed_by_id"
    t.index ["status"], name: "index_gwana_update_requests_on_status"
  end

  create_table "gwanas", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.text "bio"
    t.string "profession"
    t.text "skills"
    t.string "region"
    t.boolean "available_for_mentorship", default: false, null: false
    t.string "linkedin_url"
    t.string "twitter_url"
    t.string "website_url"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "phone"
    t.bigint "commune_id"
    t.text "experiences"
    t.text "formations"
    t.index ["available_for_mentorship"], name: "index_gwanas_on_available_for_mentorship"
    t.index ["commune_id"], name: "index_gwanas_on_commune_id"
    t.index ["phone"], name: "index_gwanas_on_phone_unique", unique: true, where: "(phone IS NOT NULL)"
    t.index ["region"], name: "index_gwanas_on_region"
    t.index ["slug"], name: "index_gwanas_on_slug", unique: true
    t.index ["user_id"], name: "index_gwanas_on_user_id", unique: true
  end

  create_table "mentorship_requests", force: :cascade do |t|
    t.bigint "requester_id", null: false
    t.bigint "mentor_id", null: false
    t.text "message"
    t.text "objectives"
    t.string "desired_duration"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "motivation"
    t.bigint "commune_id"
    t.string "niveau_etudes"
    t.string "filiere"
    t.index ["commune_id"], name: "index_mentorship_requests_on_commune_id"
    t.index ["mentor_id"], name: "index_mentorship_requests_on_mentor_id"
    t.index ["requester_id"], name: "index_mentorship_requests_on_requester_id"
    t.index ["status"], name: "index_mentorship_requests_on_status"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "country_code"
    t.integer "profile", default: 0, null: false
    t.boolean "is_verified", default: false, null: false
    t.string "otp"
    t.datetime "otp_sent_at"
    t.datetime "deleted_at"
    t.integer "gender"
    t.date "date_of_birth"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_verified"], name: "index_users_on_is_verified"
    t.index ["phone"], name: "index_users_on_phone"
    t.index ["profile"], name: "index_users_on_profile"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "communes", "departments"
  add_foreign_key "departments", "regions"
  add_foreign_key "gwana_activities", "gwanas"
  add_foreign_key "gwana_update_requests", "gwanas"
  add_foreign_key "gwana_update_requests", "users", column: "reviewed_by_id"
  add_foreign_key "gwanas", "communes"
  add_foreign_key "gwanas", "users"
  add_foreign_key "mentorship_requests", "communes"
  add_foreign_key "mentorship_requests", "users", column: "mentor_id"
  add_foreign_key "mentorship_requests", "users", column: "requester_id"
end
