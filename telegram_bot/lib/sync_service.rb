require 'pg'
require 'dotenv'

Dotenv.load

# Сервис для синхронизации вишлистов из веб-приложения в бот
class SyncService
  def initialize
    @web_db = PG.connect(
      host: ENV.fetch('WEB_DB_HOST', 'localhost'),
      port: ENV.fetch('WEB_DB_PORT', 5432),
      dbname: ENV.fetch('WEB_DB_NAME', 'wishlist_web_db'),
      user: ENV.fetch('WEB_DB_USER', 'postgres'),
      password: ENV.fetch('WEB_DB_PASSWORD', 'postgres')
    )
  end

  def sync_wishlist_to_bot(web_wishlist_id, telegram_user_id)
    # Получаем вишлист из веб-БД
    result = @web_db.exec_params(
      'SELECT id, name, event_date FROM wishlists WHERE id = $1',
      [web_wishlist_id]
    )

    return nil if result.ntuples == 0

    wishlist_data = result[0]
    
    # Создаем или обновляем вишлист в БД бота
    user = User.find_by(telegram_id: telegram_user_id)
    return nil unless user

    wishlist = Wishlist.find_or_initialize_by(web_wishlist_id: web_wishlist_id)
    wishlist.user = user
    wishlist.name = wishlist_data['name']
    wishlist.event_date = Date.parse(wishlist_data['event_date'])
    wishlist.save!

    wishlist
  end

  def close
    @web_db.close if @web_db
  end
end

