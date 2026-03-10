class TelegramUser < ApplicationRecord
  has_many :wishlists, foreign_key: :telegram_id, primary_key: :telegram_id, dependent: :destroy
  validates :telegram_id, presence: true, uniqueness: true
end
