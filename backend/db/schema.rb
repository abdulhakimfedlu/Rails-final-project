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

ActiveRecord::Schema[8.0].define(version: 2025_07_29_203015) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "name", default: ""
    t.string "phone", default: ""
    t.text "comment", null: false
    t.boolean "anonymous", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "image"
    t.string "position", null: false
    t.decimal "salary", precision: 10, scale: 2, null: false
    t.datetime "date_hired", default: -> { "CURRENT_TIMESTAMP" }
    t.string "table_assigned"
    t.text "description", default: ""
    t.string "working_hour", default: ""
    t.string "status", default: "active"
    t.text "reason_for_leaving", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_employees_on_phone", unique: true
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.text "ingredients"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "image"
    t.boolean "available", default: true
    t.boolean "out_of_stock", default: false
    t.string "badge"
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_menus_on_category_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "stars", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_ratings_on_menu_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "menus", "categories"
  add_foreign_key "ratings", "menus"
end
