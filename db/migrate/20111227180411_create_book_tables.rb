class CreateBookTables < ActiveRecord::Migration
  def change
    
    # Books
    create_table :products do |t|
      t.string :title
      t.integer :author_id
      t.integer :illustrator_id
      t.integer :age_from
      t.integer :age_to
      t.integer :publisher_id
      t.integer :year
      t.string :flipkart_id
      t.string :amazon_url
      t.text :short_description
      t.string :accession_id
      t.timestamps
    end
    add_index :products, :title, :unique => true
    add_index :products, :author_id
    add_index :products, :illustrator_id
    add_index :products, :publisher_id
    add_index :products, [:age_from, :age_to]
    add_index :products, :accession_id, :unique => true
    
    # Editions
    create_table :editions do |t|
      t.integer :product_id
      t.column :isbn, :bigint
      t.integer :base_price
      t.integer :format_id
      t.timestamps
    end
    add_index :editions, :product_id
    add_index :editions, :isbn, :unique => true
    add_index :editions, :format_id
    
    # Copies
    create_table :copies do |t|
      t.integer :edition_id
      t.string :accession_id
      t.text :condition_description
      t.column :condition_rating, :smallint
      t.timestamps
    end
    add_index :copies, :edition_id
    add_index :copies, :accession_id, :unique => true
    add_index :copies, :condition_rating
    
    # Formats
    create_table :formats do |t|
      t.string :name
      t.timestamps
    end
    add_index :formats, :name, :unique => true
    
    # Authors
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
    add_index :authors, [:last_name, :first_name]
    
    # Illustrators
    create_table :illustrators do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
    add_index :illustrators, [:last_name, :first_name]
    
    # Publishers
    create_table :publishers do |t|
      t.string :name
      t.timestamps
    end
    add_index :publishers, :name, :unique => true
    
    # Product tags
    create_table :product_tags do |t|
      t.string :name
      t.timestamps
    end
    add_index :product_tags, :name, :unique => true
    
    # Products - product tags
    create_table :products_product_tags, :id => false do |t|
      t.integer :product_id
      t.integer :product_tag_id
    end
    add_index :products_product_tags, [:product_id, :product_tag_id], :unique => true
    add_index :products_product_tags, :product_id
    
    # Keywords
    create_table :keywords do |t|
      t.string :name
      t.timestamps
    end
    add_index :keywords, :name, :unique => true
    
    # Products - keywords
    create_table :products_keywords, :id => false do |t|
      t.integer :product_id
      t.integer :keyword_id
    end
    add_index :products_keywords, [:product_id, :keyword_id], :unique => true
    add_index :products_keywords, :product_id
    
    # Genres
    create_table :genres do |t|
      t.string :name
      t.timestamps
    end
    add_index :genres, :name, :unique => true
    
    # Products - genres
    create_table :products_genres, :id => false do |t|
      t.integer :product_id
      t.integer :genre_id
    end
    add_index :products_genres, [:product_id, :genre_id], :unique => true
    add_index :products_genres, :product_id
    
    # Award Types
    create_table :award_types do |t|
      t.string :name
      t.timestamps
    end
    add_index :award_types, :name, :unique => true
    
    # Awards
    create_table :awards do |t|
      t.integer :award_type_id
      t.string :name
      t.timestamps
    end
    add_index :awards, :name
    add_index :awards, :award_type_id
    
    # Products - awards
    create_table :products_awards do |t|
      t.integer :product_id
      t.integer :award_id
      t.integer :year
    end
    add_index :products_awards, [:product_id, :award_id]
    add_index :products_awards, :product_id
    
    # Other fields
    create_table :other_fields do |t|
      t.integer :product_id
      t.string :title
      t.text :content
    end
    add_index :other_fields, :product_id
    
  end
end
