# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    association :author, factory: :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    category { Faker::Lorem.word }
    tags { Faker::Lorem.words(number: 3).join(", ") }
    published { false }

    trait :published do
      published { true }
      published_at { Time.current }
    end
  end
end

