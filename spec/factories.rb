require 'factory_girl'

FactoryGirl.define do
  sequence(:random_string) { |n| rand(36**8).to_s(36) + n.to_s }

  factory :book do
    ignore do
      price 50
    end

    sequence(:title) { |n| "Book #{n}" }
    author

    factory :book_with_used_copy do
      after(:create) do |book, evaluator|
        create(:edition_with_used_copy, book: book, price: evaluator.price)
      end
    end

    factory :book_with_new_copy do
      after(:create) do |book, evaluator|
        create(:edition_with_new_copy, book: book, price: evaluator.price)
      end
    end
  end

  factory :author do
    sequence(:name) { |n| "Test Author #{n}" }

    factory :random_author do
      name { generate(:random_string) }
    end
  end

  factory :illustrator do
    sequence(:name) { |n| "Test Illustrator #{n}" }
  end

  factory :publisher do
    sequence(:name) { |n| "Test Publisher #{n}" }
  end

  factory :country do
    sequence(:name) { |n| "Country #{n}"}
  end

  factory :book_type do
    sequence(:name) { |n| "Book Type #{n}"}
  end

  factory :collection do
    sequence(:name) { |n| "Collection #{n}"}
  end

  factory :award_type do
    sequence(:name) { |n| "Award Type #{n}"}
  end

  factory :award do
    sequence(:name) { |n| "Award #{n}"}
    award_type
  end

  factory :book_award do
    award
    year 2000

    factory :book_award_with_book do
      book
    end
  end

  factory :description do
    book
    title "Description Title"
    content "Description Content\nMore content"
  end

  factory :cover_image do
    filename { File.open(File.join(Rails.root, 'public', 'images', 'title.png')) }
  end

  factory :format do
    sequence(:name) { |n| "Format #{n}"}
  end

  factory :language do
    sequence(:name) { |n| "Language #{n}"}
  end

  factory :edition do
    ignore do
      price 50
    end

    format
    
    factory :edition_with_book do
      book
    end

    factory :edition_with_used_copy do
      after(:create) do |edition, evaluator|
       create(:used_copy, edition: edition, price: evaluator.price)
      end
    end

    factory :edition_with_new_copy do
      after(:create) do |edition, evaluator|
       create(:new_copy, edition: edition, stock: 1, price: evaluator.price)
      end
    end
  end

  factory :used_copy do
    price 50

    factory :used_copy_with_book do
      association :edition, factory: :edition_with_book
    end
  end

  factory :new_copy do
    price 100
    required_stock 10
    
    factory :new_copy_with_book do
      association :edition, factory: :edition_with_book
    end
  end

  factory :pickup_point do
    sequence(:name) { |n| "Pickup Point #{n}"}
  end

  factory :payment_method do
    sequence(:name) { |n| "Payment Method #{n}"}
  end

  factory :customer do
    delivery_method 1
    order

    factory :valid_customer do
      payment_method
      name "Test Customer"
      email "test@email.com"
    end
  end

  factory :order do
  end

  factory :complete_order do
    
    factory :complete_order_with_customer do
      after(:create) do |order|
        create(:valid_customer, complete_order: order)
      end
    end
  end

  factory :order_copy do
    association :copy, factory: :used_copy_with_book
  end

  factory :default_cost_price do
    format 
    book_type
    cost_price 30
  end

  factory :extra_cost do
    sequence(:name) { |n| "Extra Cost #{n}"}
    amount 40
  end

  factory :transaction_category do
    sequence(:name) { |n| "Transaction Category #{n}"}
  end

  factory :transaction do
    transaction_category

    factory :transaction_with_assoc do
      payment_method
      complete_order
    end
  end
end
