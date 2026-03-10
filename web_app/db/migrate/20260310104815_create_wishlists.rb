class CreateWishlists < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlists do |t|
      t.string :name
      t.date :event_date

      t.timestamps
    end
  end
end
