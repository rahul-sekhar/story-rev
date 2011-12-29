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

ActiveRecord::Schema.define(:version => 20111227180411) do

  create_table "authors", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "copies", :force => true do |t|
    t.integer  "edition_id"
    t.string   "accession_id"
    t.text     "condition_description"
    t.integer  "condition_rating",      :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "copies", ["accession_id"], :name => "index_copies_on_accession_id", :unique => true
  add_index "copies", ["condition_rating"], :name => "index_copies_on_condition_rating"
  add_index "copies", ["edition_id"], :name => "index_copies_on_edition_id"

  create_table "editions", :force => true do |t|
    t.integer  "product_id"
    t.integer  "isbn",       :limit => 8
    t.integer  "base_price"
    t.integer  "format_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editions", ["format_id"], :name => "index_editions_on_format_id"
  add_index "editions", ["isbn"], :name => "index_editions_on_isbn", :unique => true
  add_index "editions", ["product_id"], :name => "index_editions_on_product_id"

  create_table "formats", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formats", ["name"], :name => "index_formats_on_name", :unique => true

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genres", ["name"], :name => "index_genres_on_name", :unique => true

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

  create_table "other_fields", :force => true do |t|
    t.integer "product_id"
    t.string  "title"
    t.text    "content"
  end

  add_index "other_fields", ["product_id"], :name => "index_other_fields_on_product_id"

  create_table "product_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_tags", ["name"], :name => "index_product_tags_on_name", :unique => true

  create_table "products", :force => true do |t|
    t.string   "title"
    t.integer  "author_id"
    t.integer  "illustrator_id"
    t.integer  "age_from"
    t.integer  "age_to"
    t.integer  "publisher_id"
    t.integer  "year"
    t.string   "flipkart_id"
    t.string   "amazon_url"
    t.text     "short_description"
    t.string   "accession_id"
    t.string   "cover_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["accession_id"], :name => "index_products_on_accession_id", :unique => true
  add_index "products", ["age_from", "age_to"], :name => "index_products_on_age_from_and_age_to"
  add_index "products", ["author_id"], :name => "index_products_on_author_id"
  add_index "products", ["illustrator_id"], :name => "index_products_on_illustrator_id"
  add_index "products", ["publisher_id"], :name => "index_products_on_publisher_id"
  add_index "products", ["title"], :name => "index_products_on_title", :unique => true

  create_table "products_awards", :force => true do |t|
    t.integer "product_id"
    t.integer "award_id"
    t.integer "year"
  end

  add_index "products_awards", ["product_id", "award_id"], :name => "index_products_awards_on_product_id_and_award_id"
  add_index "products_awards", ["product_id"], :name => "index_products_awards_on_product_id"

  create_table "products_genres", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "genre_id"
  end

  add_index "products_genres", ["product_id", "genre_id"], :name => "index_products_genres_on_product_id_and_genre_id", :unique => true
  add_index "products_genres", ["product_id"], :name => "index_products_genres_on_product_id"

  create_table "products_keywords", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "keyword_id"
  end

  add_index "products_keywords", ["product_id", "keyword_id"], :name => "index_products_keywords_on_product_id_and_keyword_id", :unique => true
  add_index "products_keywords", ["product_id"], :name => "index_products_keywords_on_product_id"

  create_table "products_product_tags", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_tag_id"
  end

  add_index "products_product_tags", ["product_id", "product_tag_id"], :name => "index_products_product_tags_on_product_id_and_product_tag_id", :unique => true
  add_index "products_product_tags", ["product_id"], :name => "index_products_product_tags_on_product_id"

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publishers", ["name"], :name => "index_publishers_on_name", :unique => true

end
