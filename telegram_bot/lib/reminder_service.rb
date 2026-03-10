require 'rufus-scheduler'
require 'date'
require 'pg'

class ReminderService
  def initialize(bot)
    @bot = bot
    @scheduler = Rufus::Scheduler.new
  end

  def start
    # Проверяем вишлисты каждый день в 9:00
    @scheduler.cron '0 9 * * *' do
      check_upcoming_events
    end
  end

  def stop
    @scheduler.shutdown
  end

  private

  def check_upcoming_events
    today = Date.today
    upcoming_date = today + 7

    # Подключаемся к общей БД
    db = PG.connect(
      host: ENV.fetch('DB_HOST', 'localhost'),
      port: ENV.fetch('DB_PORT', 5432),
      dbname: ENV.fetch('DB_NAME', 'wishlist_web_db'),
      user: ENV.fetch('DB_USER', 'postgres'),
      password: ENV.fetch('DB_PASSWORD', 'postgres')
    )

    # Получаем вишлисты с датами в нужном диапазоне и с telegram_id
    result = db.exec_params(
      "SELECT w.id, w.name, w.event_date, w.telegram_id 
       FROM wishlists w 
       WHERE w.event_date BETWEEN $1 AND $2 
       AND w.telegram_id IS NOT NULL",
      [today, upcoming_date]
    )

    result.each do |wishlist_data|
      wishlist_id = wishlist_data['id'].to_i
      wishlist_name = wishlist_data['name']
      event_date = Date.parse(wishlist_data['event_date'])
      telegram_id = wishlist_data['telegram_id'].to_i
      
      days_until = (event_date - today).to_i
      
      # Получаем подарки для этого вишлиста
      gifts_result = db.exec_params(
        'SELECT name, price FROM gifts WHERE wishlist_id = $1 ORDER BY created_at DESC LIMIT 3',
        [wishlist_id]
      )
      
      gifts = gifts_result.to_a
      
      # Формируем сообщение
      message = build_reminder_message(wishlist_name, event_date, days_until, gifts)
      
      if message
        begin
          @bot.api.send_message(
            chat_id: telegram_id,
            text: message,
            parse_mode: 'Markdown'
          )
        rescue => e
          puts "Ошибка отправки сообщения пользователю #{telegram_id}: #{e.message}"
        end
      end
    end

    db.close
  end

  def build_reminder_message(name, event_date, days_until, gifts)
    date_str = event_date.strftime('%d.%m.%Y')
    
    # Формируем основное сообщение
    if days_until == 0
      message = "🎉 *Сегодня событие: #{name}!*\n"
      message += "📅 Дата: #{date_str}\n\n"
    elsif days_until == 7
      message = "⏰ *Осталось 7 дней до даты*\n"
      message += "📅 *#{name}*\n"
      message += "📆 Дата: #{date_str}\n\n"
    elsif days_until <= 3
      days_word = case days_until
      when 1 then "день"
      when 2, 3, 4 then "дня"
      else "дней"
      end
      message = "⏰ *Осталось #{days_until} #{days_word} до даты*\n"
      message += "📅 *#{name}*\n"
      message += "📆 Дата: #{date_str}\n\n"
    else
      return nil
    end
    
    # Добавляем информацию о подарках
    if gifts.any?
      message += "🎁 *Вы выбрали подарки:*\n"
      gifts.each_with_index do |gift, index|
        gift_name = gift['name']
        gift_price = gift['price']
        price_text = gift_price && gift_price.to_f > 0 ? " (#{gift_price.to_f} руб.)" : ""
        message += "• #{gift_name}#{price_text}\n"
      end
      if gifts.size == 3
        message += "\n💡 И еще подарки... Откройте миниапп чтобы увидеть все!"
      end
    else
      message += "💡 Пока нет подарков в вишлисте. Добавьте их в миниаппе!"
    end
    
    message
  end
end
