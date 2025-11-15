# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    association :user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    bio { Faker::Lorem.paragraph }
    profession { Faker::Job.title }
    skills { Faker::Job.key_skill }
    region { Faker::Address.state }
    available_for_mentorship { false }

    trait :available_for_mentorship do
      available_for_mentorship { true }
    end
  end
end

