FactoryBot.define do
  factory :menu do
    association :category
    name { "Delicious Dish" }
    price { 15.99 }
    badge { "" }

    trait :new_item do
      badge { "New" }
    end

    trait :popular do
      badge { "Popular" }
    end

    trait :recommended do
      badge { "Recommended" }
    end

    trait :vegan do
      badge { "Vegan" }
    end
  end
end