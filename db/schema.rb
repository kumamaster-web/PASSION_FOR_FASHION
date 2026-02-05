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

<<<<<<< HEAD
ActiveRecord::Schema[7.1].define(version: 2026_02_03_110348) do
=======
ActiveRecord::Schema[7.1].define(version: 2026_02_05_102722) do
>>>>>>> 1ec03caf1165be51aa0a30d81f70fbb9dd3847f2
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "fashion_answer_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fashion_answer_id"], name: "index_chats_on_fashion_answer_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "fashion_answers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "image_path"
    t.string "lifestyle"
    t.string "colors"
    t.string "occasion"
    t.string "comfort"
    t.string "statement"
    t.string "personality_type"
    t.text "style"
    t.text "colour_palette"
    t.text "recommended_brands"
    t.text "where_to_shop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "persona"
    t.string "gender"
    t.integer "price_min"
    t.integer "price_max"
    t.string "currency"
    t.index ["user_id"], name: "index_fashion_answers_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "role"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "fashion_answers"
  add_foreign_key "chats", "users"
  add_foreign_key "fashion_answers", "users"
  add_foreign_key "messages", "chats"
end
