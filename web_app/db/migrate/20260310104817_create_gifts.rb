class CreateGifts < ActiveRecord::Migration[8.0]
  def change
    create_table :gifts do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.string :name
      t.decimal :price
      t.string :image_url
      t.string :link_url
      t.text :additional_info

      t.timestamps
    end
  end
end
