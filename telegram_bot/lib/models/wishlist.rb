class Wishlist < ActiveRecord::Base
  belongs_to :user, foreign_key: :telegram_id, primary_key: :telegram_id, optional: true
  validates :name, presence: true
  validates :event_date, presence: true
  
  # Метод для получения подарков из веб-БД
  def gifts_from_web_db
    return [] unless self.id
    
    require 'pg'
    web_db = PG.connect(
      host: ENV.fetch('DB_HOST', 'localhost'),
      port: ENV.fetch('DB_PORT', 5432),
      database: ENV.fetch('DB_NAME', 'wishlist_web_db'),
      user: ENV.fetch('DB_USER', 'postgres'),
      password: ENV.fetch('DB_PASSWORD', 'postgres')
    )
    
    result = web_db.exec_params(
      'SELECT name, price, link_url FROM gifts WHERE wishlist_id = $1 ORDER BY created_at DESC LIMIT 5',
      [self.id]
    )
    web_db.close
    
    result.to_a
  end
end

