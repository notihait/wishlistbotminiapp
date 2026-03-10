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

ActiveRecord::Schema[8.0].define(version: 2026_03_10_112248) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "gifts", id: :serial, force: :cascade do |t|
    t.integer "wishlist_id", null: false
    t.string "name", limit: 255, null: false
    t.decimal "price", precision: 10, scale: 2
    t.string "image_url", limit: 500
    t.string "link_url", limit: 500
    t.text "additional_info"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["wishlist_id"], name: "idx_gifts_wishlist_id"
  end

  create_table "telegram_users", force: :cascade do |t|
    t.bigint "telegram_id"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telegram_id"], name: "index_telegram_users_on_telegram_id", unique: true
  end

  create_table "wishlists", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.date "event_date", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "telegram_id"
    t.index ["telegram_id"], name: "index_wishlists_on_telegram_id"
  end

  add_foreign_key "gifts", "wishlists", name: "gifts_wishlist_id_fkey", on_delete: :cascade
end
