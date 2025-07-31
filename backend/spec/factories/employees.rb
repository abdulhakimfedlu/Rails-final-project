FactoryBot.define do
  factory :employee do
    name { "Jane Smith" }
    sequence(:phone) { |n| "555-100-#{n.to_s.rjust(4, '0')}" }
    position { "waiter" }
    salary { 35000 }
    table_assigned { "Table 5" }
    status { "active" }

    trait :cashier do
      position { "cashier" }
      table_assigned { nil }
    end

    trait :manager do
      position { "manager" }
      salary { 55000 }
      table_assigned { nil }
    end

    trait :fired do
      status { "fired" }
      reason_for_leaving { "Performance issues" }
    end

    trait :resigned do
      status { "resigned" }
      reason_for_leaving { "Found better opportunity" }
    end
  end
end