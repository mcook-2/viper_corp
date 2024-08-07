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

ActiveRecord::Schema[7.1].define(version: 2024_08_05_035924) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.text "shipping_address"
    t.text "billing_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.decimal "subtotal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.datetime "order_date"
    t.string "status"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "card_number"
    t.string "expiration_date"
    t.string "cvv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payment_methods_on_customer_id"
  end

  create_table "product_prices", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "features"
    t.integer "stock_quantity"
    t.bigint "category_id", null: false
    t.bigint "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "customer_id", null: false
    t.integer "rating"
    t.text "comment"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_reviews_on_customer_id"
    t.index ["product_id"], name: "index_reviews_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "admins", "users"
  add_foreign_key "customers", "users"
  add_foreign_key "images", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "payment_methods", "customers"
  add_foreign_key "product_prices", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "customers"
  add_foreign_key "reviews", "products"
end
