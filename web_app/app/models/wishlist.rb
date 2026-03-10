class Wishlist < ApplicationRecord
  has_many :gifts, dependent: :destroy
  belongs_to :telegram_user, optional: true, foreign_key: :telegram_id, primary_key: :telegram_id
  validates :name, presence: true
  validates :event_date, presence: true
end
