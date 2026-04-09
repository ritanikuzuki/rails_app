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

ActiveRecord::Schema[7.2].define(version: 2026_04_10_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charges", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.string "stripe_charge_id"
    t.string "stripe_transfer_id"
    t.integer "status", default: 0, null: false
    t.string "donation_destination"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_charge_id"], name: "index_charges_on_stripe_charge_id"
    t.index ["task_id"], name: "index_charges_on_task_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "title", null: false
    t.boolean "completed", default: false
    t.date "due_date"
    t.integer "position", default: 0
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "position"], name: "index_milestones_on_task_id_and_position"
    t.index ["task_id"], name: "index_milestones_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "penalty_amount"
    t.integer "priority", default: 3, null: false
    t.integer "status", default: 0, null: false
    t.date "start_date"
    t.date "due_date", null: false
    t.datetime "completed_at"
    t.boolean "charged", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date", "status", "charged"], name: "index_tasks_on_due_date_and_status_and_charged"
    t.index ["user_id", "due_date"], name: "index_tasks_on_user_id_and_due_date"
    t.index ["user_id", "penalty_amount"], name: "index_tasks_on_user_id_and_penalty_amount"
    t.index ["user_id", "status"], name: "index_tasks_on_user_id_and_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "avatar_url"
    t.string "stripe_customer_id"
    t.boolean "card_registered", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "charges", "tasks"
  add_foreign_key "charges", "users"
  add_foreign_key "milestones", "tasks"
  add_foreign_key "tasks", "users"
end
