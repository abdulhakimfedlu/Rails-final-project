FactoryBot.define do
  factory :user do
    name { "John Doe" }
    sequence(:phone) { |n| "555-000-#{n.to_s.rjust(4, '0')}" }
    password { "password123" }
  end
end