FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:slug) { |n| "organization-#{n}" }
  end

  factory :user do
    association :organization
    sequence(:email) { |n| "user#{n}@example.test" }
    password { "SafePass!2026" }
    full_name { "Demo User" }
    role { :advisor }
  end

  factory :household do
    association :organization
    sequence(:name) { |n| "Household #{n}" }
  end

  factory :client do
    association :organization
    first_name { "Alex" }
    last_name { "Demo" }
    sequence(:email) { |n| "client#{n}@example.test" }
    status { :active }
    estimated_aum { 100_000 }
  end

  factory :opportunity do
    association :organization
    association :client, strategy: :build
    association :owner_user, factory: :user, strategy: :build
    title { "Retirement planning" }
    stage { :qualified }
    estimated_value { 250_000 }
    after(:build) do |opportunity|
      opportunity.client.organization = opportunity.organization
      opportunity.owner_user.organization = opportunity.organization
    end
  end

  factory :activity do
    association :organization
    association :client, strategy: :build
    association :user, strategy: :build
    activity_type { :note }
    summary { "Discussed planning priorities." }
    occurred_at { Time.current }
    after(:build) do |activity|
      activity.client.organization = activity.organization
      activity.user.organization = activity.organization
    end
  end
end
