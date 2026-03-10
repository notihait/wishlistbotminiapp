class CreateTelegramUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :telegram_users do |t|
      t.bigint :telegram_id
      t.string :username
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
    add_index :telegram_users, :telegram_id, unique: true
  end
end
