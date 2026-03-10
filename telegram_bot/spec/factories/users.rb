FactoryBot.define do
  factory :user do
    telegram_id { rand(100000000..999999999) }
    username { "user#{rand(1000)}" }
    first_name { "Test" }
    last_name { "User" }
  end
end

