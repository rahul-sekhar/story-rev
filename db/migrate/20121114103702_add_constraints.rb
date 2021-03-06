class AddConstraints < ActiveRecord::Migration
  def up
    Copy.reset_column_information
    OrderCopy.reset_column_information
    
    a = DuplicateNames::Handler.new(Author, :books, :author_id, true)
    a.merge_duplicates

    i = DuplicateNames::Handler.new(Illustrator, :books, :illustrator_id, true)
    i.merge_duplicates

    puts "\t\n\n*** REMEMBER TO CHECK FOR DUPLICATE BOOKS ***\n\n"

    puts "Removing invalid or duplicate email addresses:"
    EmailSubscription.all.each do |x|
      if x.invalid?
        puts "\t-#{x.email}"
        x.destroy
      end
    end
      
    # Admin roles
    change_column :admin_roles, :name, :string, null: false, limit: 100
    change_column :admin_roles, :password_hash, :string, null: false
    change_column :admin_roles, :password_salt, :string, null: false

    add_index :admin_roles, :name, unique: true
    
    # Authors
    change_column :authors, :first_name, :string, limit: 100
    change_column :authors, :last_name, :string, null: false, limit: 100

    remove_index :authors, [:last_name, :first_name]
    add_index :authors, [:last_name, :first_name], unique: true

    # Award Types
    change_column :award_types, :name, :string, null: false, limit: 100

    # Awards
    change_column :awards, :award_type_id, :integer, null: false
    change_column :awards, :name, :string, null: false, limit: 150

    remove_index :awards, :name
    add_index :awards, [:award_type_id, :name], unique: true

    # Book types
    change_column :book_types, :name, :string, null: false, limit: 100

    remove_index :book_types, name: :index_product_types_on_name
    add_index :book_types, :name, unique: true

    # Books
    change_column :books, :title, :string, null: false, limit: 255
    change_column :books, :author_id, :integer, null: false
    change_column :books, :amazon_url, :string, limit: 255
    change_column :books, :in_stock, :boolean, null: false, default: false
    change_column :books, :accession_id, :integer, null: false

    remove_index :books, name: :index_products_on_accession_id
    add_index :books, :accession_id, unique: true

    # Books Awards
    change_column :books_awards, :book_id, :integer, null: false
    change_column :books_awards, :award_id, :integer, null: false

    # Books collections
    change_column :books_collections, :book_id, :integer, null: false
    change_column :books_collections, :collection_id, :integer, null: false

    # Collections
    change_column :collections, :name, :string, null: false, limit: 200

    add_index :collections, :name, unique: true

    # Copies
    change_column :copies, :edition_id, :integer, null: false
    change_column :copies, :new_copy, :boolean, null: false, default: false
    change_column :copies, :stock, :integer, null: false
    change_column :copies, :accession_id, :string, null: false
    change_column :copies, :copy_number, :integer, null: false
    change_column :copies, :condition_rating, :integer, null: false, limit: 2
    change_column :copies, :price, :integer, null: false

    remove_index :copies, :accession_id
    add_index :copies, :accession_id, unique: true
    add_index :copies, :price

    # Countries
    change_column :countries, :name, :string, null: false, limit: 100

    remove_index :countries, :name
    add_index :countries, :name, unique: true

    # Cover images
    change_column :cover_images, :filename, :string, null: false

    add_index :cover_images, :book_id, unique: true

    # Descriptions
    change_column :descriptions, :book_id, :integer, null: false
    change_column :descriptions, :title, :string, null: false, limit: 255

    # Editions
    change_column :editions, :book_id, :integer, null: false
    change_column :editions, :isbn, :string, limit: 50
    change_column_default :editions, :language_id, nil

    add_index :editions, :language_id

    # Email subscriptions
    change_column :email_subscriptions, :email, :string, null: false

    # Formats
    change_column :formats, :name, :string, null: false, limit: 100

    # Illustrators
    change_column :illustrators, :first_name, :string, limit: 100
    change_column :illustrators, :last_name, :string, null: false, limit: 100

    remove_index :illustrators, [:last_name, :first_name]
    add_index :illustrators, [:last_name, :first_name], unique: true

    # Languages
    change_column :languages, :name, :string, null: false, limit: 100

    remove_index :languages, :name
    add_index :languages, :name, unique: true

    # Pickup points
    change_column :pickup_points, :name, :string, null: false, limit: 255

    add_index :pickup_points, :name, unique: true

    # Publishers
    change_column :publishers, :name, :string, null: false, limit: 150

    # Stock taking
    change_column :stock_taking, :copy_id, :integer, null: false
  end

  def down
    # Admin roles
    change_column :admin_roles, :name, :string, null: true
    change_column :admin_roles, :password_hash, :string, null: true
    change_column :admin_roles, :password_salt, :string, null: true

    remove_index :admin_roles, :name
    
    # Authors
    change_column :authors, :first_name, :string
    change_column :authors, :last_name, :string, null: true

    remove_index :authors, [:last_name, :first_name]
    add_index :authors, [:last_name, :first_name]

    # Award Types
    change_column :award_types, :name, :string, null: true

    # Awards
    change_column :awards, :award_type_id, :integer, null: true
    change_column :awards, :name, :string, null: true

    add_index :awards, :name
    remove_index :awards, [:award_type_id, :name]

    # Book types
    change_column :book_types, :name, :string, null: true

    remove_index :book_types, :name
    add_index :book_types, :name, name: :index_product_types_on_name

    # Books
    change_column :books, :title, :string, null: true
    change_column :books, :author_id, :integer, null: true
    change_column :books, :amazon_url, :string
    change_column :books, :in_stock, :boolean, null: true
    change_column_default :books, :in_stock, nil
    change_column :books, :accession_id, :integer, null: true

    remove_index :books, :accession_id
    add_index :books, :accession_id, name: :index_products_on_accession_id

    # Books Awards
    change_column :books_awards, :book_id, :integer, null: true
    change_column :books_awards, :award_id, :integer, null: true

    # Books collections
    change_column :books_collections, :book_id, :integer, null: true
    change_column :books_collections, :collection_id, :integer, null: true

    # Collections
    change_column :collections, :name, :string, null: true

    remove_index :collections, :name

    # Copies
    change_column :copies, :edition_id, :integer, null: true
    change_column :copies, :new_copy, :boolean, null: true
    change_column_default :copies, :new_copy, nil
    change_column :copies, :stock, :integer, null: true
    change_column :copies, :accession_id, :string, null: true
    change_column :copies, :copy_number, :integer, null: true
    change_column :copies, :condition_rating, :integer, null: true, limit: 2
    change_column :copies, :price, :integer, null: true

    remove_index :copies, :accession_id
    add_index :copies, :accession_id
    remove_index :copies, :price

    # Countries
    change_column :countries, :name, :string, null: true

    remove_index :countries, :name
    add_index :countries, :name

    # Cover images
    change_column :cover_images, :filename, :string, null: true

    remove_index :cover_images, :book_id

    # Descriptions
    change_column :descriptions, :book_id, :integer, null: true
    change_column :descriptions, :title, :string, null: true

    # Editions
    change_column :editions, :book_id, :integer, null: true
    change_column :editions, :isbn, :string
    change_column_default :editions, :language_id, 1

    remove_index :editions, :language_id

    # Email subscriptions
    change_column :email_subscriptions, :email, :string, null: true

    # Formats
    change_column :formats, :name, :string, null: true

    # Illustrators
    change_column :illustrators, :first_name, :string
    change_column :illustrators, :last_name, :string, null: true

    remove_index :illustrators, [:last_name, :first_name]
    add_index :illustrators, [:last_name, :first_name]

    # Languages
    change_column :languages, :name, :string, null: true

    remove_index :languages, :name
    add_index :languages, :name

    # Pickup points
    change_column :pickup_points, :name, :string, null: true

    remove_index :pickup_points, :name

    # Publishers
    change_column :publishers, :name, :string, null: true

    # Stock taking
    change_column :stock_taking, :copy_id, :integer, null: true
  end
end
