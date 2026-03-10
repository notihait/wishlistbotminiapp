FactoryBot.define do
  factory :wishlist do
    association :user
    name { "Test Wishlist #{rand(1000)}" }
    event_date { Date.today + rand(1..30) }
    web_wishlist_id { nil }
  end
end

