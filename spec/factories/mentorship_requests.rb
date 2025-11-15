# frozen_string_literal: true

FactoryBot.define do
  factory :mentorship_request do
    association :requester, factory: :user
    association :mentor, factory: [:user, :mentor]
    message { Faker::Lorem.paragraph }
    objectives { Faker::Lorem.sentence }
    desired_duration { "3 mois" }
    status { :pending }

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end

