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

ActiveRecord::Schema.define(version: 2022_03_20_064026) do

  create_table "channel_users", charset: "utf8mb4", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "user_id"
    t.string "username", limit: 40
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "channels", charset: "utf8mb4", force: :cascade do |t|
    t.string "channel_name"
    t.integer "maximum_talk"
    t.boolean "status"
    t.string "created_user", limit: 40
    t.string "updated_user", limit: 40
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_name"], name: "index_channels_on_channel_name"
  end

  create_table "logs", charset: "utf8mb4", force: :cascade do |t|
    t.string "roles"
    t.string "username"
    t.string "ip_addr"
    t.text "action_type"
    t.string "created_user"
    t.string "updated_user"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "messages", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "channel_id"
    t.text "message", size: :medium
    t.boolean "status"
    t.string "username", limit: 20
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["id"], name: "index_messages_on_id", unique: true
  end

  create_table "notifies", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.string "utype"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "username", limit: 20, null: false
    t.string "password", limit: 40, null: false
    t.string "email", limit: 20, null: false
    t.text "avatar", size: :long
    t.integer "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "messages", "channels"
end
