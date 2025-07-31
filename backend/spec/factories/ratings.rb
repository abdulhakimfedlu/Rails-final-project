FactoryBot.define do
  factory :rating do
    association :menu
    stars { 4 }

    trait :excellent do
      stars { 5 }
    end

    trait :poor do
      stars { 1 }
    end
  end
end