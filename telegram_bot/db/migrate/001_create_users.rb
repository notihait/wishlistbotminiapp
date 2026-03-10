class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.bigint :telegram_id, null: false, index: { unique: true }
      t.string :username
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end

