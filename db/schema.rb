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

ActiveRecord::Schema.define(version: 20161019181935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "subdomain"
    t.integer  "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "adjustment_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "adjustments", force: :cascade do |t|
    t.integer  "adjustment_type_id"
    t.integer  "product_id"
    t.integer  "adjusted_quantity"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "user_date"
    t.integer  "location_id"
    t.index ["adjustment_type_id"], name: "index_adjustments_on_adjustment_type_id", using: :btree
    t.index ["location_id"], name: "index_adjustments_on_location_id", using: :btree
    t.index ["product_id"], name: "index_adjustments_on_product_id", using: :btree
  end

  create_table "amazon_statements", force: :cascade do |t|
    t.string   "settlement_id"
    t.string   "period"
    t.decimal  "deposit_total"
    t.json     "summary"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "status"
    t.string   "report_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "email_address"
    t.string   "phone_number"
    t.integer  "qbo_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.string   "primary_marketplace_id"
    t.string   "merchant_id"
    t.string   "auth_token"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_receipts", force: :cascade do |t|
    t.string   "description"
    t.integer  "qbo_account_id"
    t.datetime "user_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["qbo_account_id"], name: "index_expense_receipts_on_qbo_account_id", using: :btree
  end

  create_table "expenses", force: :cascade do |t|
    t.integer  "expense_receipt_id"
    t.integer  "qbo_account_id"
    t.string   "description"
    t.decimal  "amount"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["expense_receipt_id"], name: "index_expenses_on_expense_receipt_id", using: :btree
    t.index ["qbo_account_id"], name: "index_expenses_on_qbo_account_id", using: :btree
  end

  create_table "inventory_movements", force: :cascade do |t|
    t.integer  "location_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.string   "movement_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["location_id"], name: "index_inventory_movements_on_location_id", using: :btree
    t.index ["product_id"], name: "index_inventory_movements_on_product_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "cost"
    t.decimal  "average_cost"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "trigger_update"
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
    t.index ["product_id"], name: "index_order_items_on_product_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.string   "name"
    t.integer  "contact_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "user_date"
    t.integer  "location_id"
    t.index ["contact_id"], name: "index_orders_on_contact_id", using: :btree
    t.index ["location_id"], name: "index_orders_on_location_id", using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "amazon_sku"
    t.decimal  "price"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "qbo_id"
    t.integer  "inventory_asset_account_id"
  end

  create_table "qbo_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "account_type"
    t.integer  "qbo_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "account_sub_type"
  end

  create_table "qbo_configs", force: :cascade do |t|
    t.string   "token"
    t.string   "secret"
    t.string   "realm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "qbo_errors", force: :cascade do |t|
    t.string   "message"
    t.text     "body"
    t.string   "resource_type", limit: 100
    t.integer  "resource_id"
    t.text     "request_xml"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "sales", force: :cascade do |t|
    t.integer  "sales_receipt_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "amount"
    t.decimal  "rate"
    t.string   "description"
    t.integer  "qbo_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["product_id"], name: "index_sales_on_product_id", using: :btree
    t.index ["sales_receipt_id"], name: "index_sales_on_sales_receipt_id", using: :btree
  end

  create_table "sales_receipts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "payment_id"
    t.datetime "user_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "location_id"
    t.index ["contact_id"], name: "index_sales_receipts_on_contact_id", using: :btree
    t.index ["location_id"], name: "index_sales_receipts_on_location_id", using: :btree
    t.index ["payment_id"], name: "index_sales_receipts_on_payment_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.string   "target_type", null: false
    t.integer  "target_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree
    t.index ["target_type", "target_id"], name: "index_settings_on_target_type_and_target_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "adjustments", "adjustment_types"
  add_foreign_key "adjustments", "locations"
  add_foreign_key "adjustments", "products"
  add_foreign_key "expense_receipts", "qbo_accounts"
  add_foreign_key "expenses", "expense_receipts"
  add_foreign_key "expenses", "qbo_accounts"
  add_foreign_key "inventory_movements", "locations"
  add_foreign_key "inventory_movements", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "contacts"
  add_foreign_key "orders", "locations"
  add_foreign_key "sales", "products"
  add_foreign_key "sales", "sales_receipts"
  add_foreign_key "sales_receipts", "contacts"
  add_foreign_key "sales_receipts", "locations"
  add_foreign_key "sales_receipts", "payments"
end
