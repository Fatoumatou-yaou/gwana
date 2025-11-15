# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    role { :member }

    trait :admin do
      role { :admin }
    end

    trait :admin_reseau do
      role { :admin_reseau }
    end

    trait :mentor do
      role { :mentor }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end

