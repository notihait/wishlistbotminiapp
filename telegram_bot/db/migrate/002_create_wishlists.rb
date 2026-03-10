class CreateWishlists < ActiveRecord::Migration[7.0]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :event_date, null: false
      t.bigint :web_wishlist_id, index: true
      t.timestamps
    end
  end
end

