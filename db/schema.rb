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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120330154305) do

  create_table "admin_roles", :force => true do |t|
    t.string   "name"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "accession_id"
  end

  add_index "authors", ["accession_id"], :name => "index_authors_on_accession_id", :unique => true
  add_index "authors", ["last_name", "first_name"], :name => "index_authors_on_last_name_and_first_name"

  create_table "award_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "award_types", ["name"], :name => "index_award_types_on_name", :unique => true

  create_table "awards", :force => true do |t|
    t.integer  "award_type_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "awards", ["award_type_id"], :name => "index_awards_on_award_type_id"
  add_index "awards", ["name"], :name => "index_awards_on_name"

  create_table "content_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_types", ["name"], :name => "index_content_types_on_name"

  create_table "copies", :force => true do |t|
    t.integer  "edition_id"
    t.string   "accession_id"
    t.string   "condition_description"
    t.integer  "condition_rating",      :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price"
    t.boolean  "in_stock"
    t.boolean  "new_copy"
    t.boolean  "limited_copies"
    t.integer  "number"
  end

  add_index "copies", ["accession_id"], :name => "index_copies_on_accession_id", :unique => true
  add_index "copies", ["condition_rating"], :name => "index_copies_on_condition_rating"
  add_index "copies", ["edition_id"], :name => "index_copies_on_edition_id"
  add_index "copies", ["in_stock"], :name => "index_copies_on_in_stock"
  add_index "copies", ["limited_copies"], :name => "index_copies_on_limited_copies"
  add_index "copies", ["new_copy"], :name => "index_copies_on_new_copy"
  add_index "copies", ["number"], :name => "index_copies_on_number"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "cover_images", :force => true do |t|
    t.integer  "product_id"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "editions", :force => true do |t|
    t.integer  "product_id"
    t.string   "isbn"
    t.integer  "format_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_isbn"
    t.integer  "publisher_id"
  end

  add_index "editions", ["format_id"], :name => "index_editions_on_format_id"
  add_index "editions", ["isbn"], :name => "index_editions_on_isbn"
  add_index "editions", ["product_id"], :name => "index_editions_on_product_id"
  add_index "editions", ["publisher_id"], :name => "index_editions_on_publisher_id"
  add_index "editions", ["raw_isbn"], :name => "index_editions_on_raw_isbn"

  create_table "formats", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formats", ["name"], :name => "index_formats_on_name", :unique => true

  create_table "illustrators", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "illustrators", ["last_name", "first_name"], :name => "index_illustrators_on_last_name_and_first_name"

  create_table "keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywords", ["name"], :name => "index_keywords_on_name", :unique => true

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["name"], :name => "index_languages_on_name"

  create_table "orders", :force => true do |t|
    t.integer  "step"
    t.integer  "shopping_cart_id"
    t.integer  "delivery_method"
    t.integer  "pickup_point_id"
    t.integer  "payment_method"
    t.text     "other_pickup"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.text     "address"
    t.string   "city"
    t.string   "pin_code"
    t.text     "other_info"
    t.integer  "postage_amount"
    t.integer  "total_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed"
    t.boolean  "paid"
    t.boolean  "packaged"
    t.boolean  "posted"
  end

  add_index "orders", ["email"], :name => "index_orders_on_email"
  add_index "orders", ["name"], :name => "index_orders_on_name"
  add_index "orders", ["pickup_point_id"], :name => "index_orders_on_pickup_point_id"
  add_index "orders", ["shopping_cart_id"], :name => "index_orders_on_shopping_cart_id"
  add_index "orders", ["step"], :name => "index_orders_on_step"

  create_table "orders_copies", :force => true do |t|
    t.integer "order_id"
    t.integer "copy_id"
    t.integer "number"
    t.boolean "ticked"
  end

  create_table "other_fields", :force => true do |t|
    t.integer  "product_id"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "other_fields", ["product_id"], :name => "index_other_fields_on_product_id"

  create_table "pickup_points", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_types", ["name"], :name => "index_product_types_on_name"

  create_table "products", :force => true do |t|
    t.string   "title"
    t.integer  "author_id"
    t.integer  "illustrator_id"
    t.integer  "age_from"
    t.integer  "age_to"
    t.integer  "year"
    t.string   "flipkart_id"
    t.string   "amazon_url"
    t.text     "short_description"
    t.string   "accession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_stock"
    t.datetime "in_stock_at"
    t.datetime "out_of_stock_at"
    t.datetime "book_date"
    t.integer  "publisher_id"
    t.integer  "country_id"
    t.integer  "language_id"
    t.integer  "product_type_id"
    t.integer  "content_type_id"
  end

  add_index "products", ["accession_id"], :name => "index_products_on_accession_id", :unique => true
  add_index "products", ["age_from", "age_to"], :name => "index_products_on_age_from_and_age_to"
  add_index "products", ["author_id"], :name => "index_products_on_author_id"
  add_index "products", ["book_date"], :name => "index_products_on_book_date"
  add_index "products", ["content_type_id"], :name => "index_products_on_content_type_id"
  add_index "products", ["country_id"], :name => "index_products_on_country_id"
  add_index "products", ["illustrator_id"], :name => "index_products_on_illustrator_id"
  add_index "products", ["in_stock"], :name => "index_products_on_in_stock"
  add_index "products", ["language_id"], :name => "index_products_on_language_id"
  add_index "products", ["product_type_id"], :name => "index_products_on_product_type_id"
  add_index "products", ["publisher_id"], :name => "index_products_on_publisher_id"
  add_index "products", ["title"], :name => "index_products_on_title", :unique => true

  create_table "products_awards", :force => true do |t|
    t.integer  "product_id"
    t.integer  "award_id"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products_awards", ["product_id", "award_id"], :name => "index_products_awards_on_product_id_and_award_id"
  add_index "products_awards", ["product_id"], :name => "index_products_awards_on_product_id"

  create_table "products_keywords", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "keyword_id"
  end

  add_index "products_keywords", ["product_id", "keyword_id"], :name => "index_products_keywords_on_product_id_and_keyword_id", :unique => true
  add_index "products_keywords", ["product_id"], :name => "index_products_keywords_on_product_id"

  create_table "products_themes", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "theme_id"
  end

  add_index "products_themes", ["product_id", "theme_id"], :name => "index_products_themes_on_product_id_and_theme_id", :unique => true
  add_index "products_themes", ["product_id"], :name => "index_products_themes_on_product_id"

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publishers", ["name"], :name => "index_publishers_on_name", :unique => true

  create_table "shopping_carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shopping_carts", ["updated_at"], :name => "index_shopping_carts_on_updated_at"

  create_table "shopping_carts_copies", :force => true do |t|
    t.integer "shopping_cart_id"
    t.integer "copy_id"
    t.integer "number"
  end

  create_table "stock_taking", :force => true do |t|
    t.integer  "copy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_taking", ["copy_id"], :name => "index_stock_taking_on_copy_id"

  create_table "theme_icons", :force => true do |t|
    t.integer  "theme_id"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "theme_icons", ["theme_id"], :name => "index_theme_icons_on_theme_id"

  create_table "themes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "themes", ["name"], :name => "index_themes_on_name"

end
