require 'factory_girl'

FactoryGirl.define do
  factory :book do
    sequence(:title) { |n| "Book #{n}" }
    author
  end

  factory :author do
    sequence(:full_name) { |n| "Test Author #{n}" }
  end

  factory :illustrator do
    sequence(:full_name) { |n| "Test Illustrator #{n}" }
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
end
