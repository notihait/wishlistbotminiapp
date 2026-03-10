class User < ActiveRecord::Base
  self.table_name = 'telegram_users'
  has_many :wishlists, foreign_key: :telegram_id, primary_key: :telegram_id
  validates :telegram_id, presence: true, uniqueness: true
end

