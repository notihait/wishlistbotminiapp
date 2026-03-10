class AddTelegramIdToWishlists < ActiveRecord::Migration[8.0]
  def change
    add_column :wishlists, :telegram_id, :bigint
    add_index :wishlists, :telegram_id
  end
end
