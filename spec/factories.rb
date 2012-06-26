require 'factory_girl'

FactoryGirl.define do
  factory :book do
    sequence(:title) { |n| "Book #{n}" }
    author
  end

  factory :author do
    sequence(:name) { |n| "Test Author #{n}" }
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
    name "Award Name"
    award_type
  end

  factory :book_award do
    award
    year 2000
  end

  factory :description do
    title "Description Title"
    content "Description Content\nMore content"
  end

  factory :cover_image do
    filename { File.open(File.join(Rails.root, 'public', 'images', 'title.png')) }
  end

  factory :format do
    sequence(:name) { |n| "Format #{n}"}
  end

  factory :edition do
    format
  end

  factory :used_copy do
    price 50
  end

  factory :new_copy do
    price 100
    required_stock 10
  end

end
