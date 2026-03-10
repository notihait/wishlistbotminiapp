# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database.

ActiveRecord::Schema.define(version: 2) do
  create_table "users", force: :cascade do |t|
    t.bigint "telegram_id", null: false
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.date "event_date", null: false
    t.bigint "web_wishlist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wishlists_on_user_id"
    t.index ["web_wishlist_id"], name: "index_wishlists_on_web_wishlist_id"
  end

  add_foreign_key "wishlists", "users"
end

