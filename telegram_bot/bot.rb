#!/usr/bin/env ruby

require_relative 'config/environment'
require 'date'
require 'pg'

Database.connect

require 'telegram/bot'
require_relative 'lib/reminder_service'

token = ENV['TELEGRAM_BOT_TOKEN']
web_app_base_url = ENV['WEB_APP_URL'] || 'https://tanna-interungular-unpresumptively.ngrok-free.dev'

# Функция для создания URL мини-аппа с telegram_id
def web_app_url(user_id = nil, path = '')
  base = ENV['WEB_APP_URL'] || 'https://tanna-interungular-unpresumptively.ngrok-free.dev'
  url = base + path
  if user_id
    separator = path.include?('?') ? '&' : '?'
    url += "#{separator}telegram_id=#{user_id}"
  end
  url
end

unless token
  puts "Error: TELEGRAM_BOT_TOKEN not set in environment"
  exit 1
end

Telegram::Bot::Client.run(token) do |bot|
  reminder_service = ReminderService.new(bot)
  reminder_service.start

  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      # Защита от неподдерживаемых типов сообщений
      unless message.text
        # Игнорируем стикеры, фото, видео и другие неподдерживаемые типы
        unsupported_types = [
          message.sticker, message.photo, message.video, message.voice,
          message.document, message.audio, message.video_note, 
          message.animation, message.location, message.contact,
          message.poll, message.dice, message.game
        ]
        
        if unsupported_types.any?
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "😊 Я понимаю только текстовые команды!\n\n💡 Используйте /help для списка команд или откройте миниапп для работы с вишлистами.",
            reply_markup: {
              inline_keyboard: [
                [
                  {
                    text: "🚀 Открыть миниапп",
                    web_app: { url: web_app_url(message.from.id) }
                  }
                ],
                [
                  {
                    text: "❓ Помощь",
                    callback_data: "help"
                  }
                ]
              ]
            }
          )
          next
        end
        
        # Если это не текстовое сообщение и не один из известных типов - просто игнорируем
        next
      end
      
      # Защита от слишком длинных сообщений (защита от спама)
      if message.text.length > 1000
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "⚠️ Сообщение слишком длинное. Пожалуйста, используйте команды или откройте миниапп.",
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🚀 Открыть миниапп",
                  web_app: { url: web_app_url }
                }
              ]
            ]
          }
        )
        next
      end
      
      case message.text
      when /^\/start/
        # Проверяем, есть ли параметр с ID вишлиста в тексте команды
        start_param = nil
        if message.text && message.text.include?(' ')
          parts = message.text.split(' ')
          start_param = parts[1] if parts.length > 1
        end

        if start_param && start_param.match?(/^\d+$/)
          # Показываем публичный вишлист
          # Ищем вишлист в веб-БД напрямую
          require 'pg'
          web_wishlist_id = start_param.to_i
          
          # Подключаемся к веб-БД для получения вишлиста
          web_db = PG.connect(
            host: ENV.fetch('WEB_DB_HOST', 'localhost'),
            port: ENV.fetch('WEB_DB_PORT', 5432),
            dbname: ENV.fetch('WEB_DB_NAME', 'wishlist_web_db'),
            user: ENV.fetch('WEB_DB_USER', 'postgres'),
            password: ENV.fetch('WEB_DB_PASSWORD', 'postgres')
          )
          
          result = web_db.exec_params(
            'SELECT id, name, event_date FROM wishlists WHERE id = $1',
            [web_wishlist_id]
          )
          
          if result.ntuples > 0
            wishlist_data = result[0]
            gifts_result = web_db.exec_params(
              'SELECT COUNT(*) as count FROM gifts WHERE wishlist_id = $1',
              [web_wishlist_id]
            )
            gifts_count = gifts_result[0]['count'].to_i
            web_db.close
          
            date_str = Date.parse(wishlist_data['event_date']).strftime('%d.%m.%Y')
            
            text = "🎁 *Вишлист: #{wishlist_data['name']}*\n\n"
            text += "📅 Дата события: #{date_str}\n"
            text += "🎁 Подарков: #{gifts_count}\n\n"
            text += "💡 Чтобы увидеть все подарки и создать свой вишлист, откройте миниапп!"
            
            bot.api.send_message(
              chat_id: message.chat.id,
              text: text,
              parse_mode: 'Markdown',
              reply_markup: {
                inline_keyboard: [
                  [
                    {
                      text: "🔗 Открыть вишлист в миниаппе",
                      web_app: { url: web_app_url(message.from.id, "/wishlists/#{web_wishlist_id}") }
                    }
                  ],
                  [
                    {
                      text: "📋 Создать свой вишлист",
                      web_app: { url: web_app_url(message.from.id) }
                    }
                  ]
                ]
              }
            )
          else
            web_db.close
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "❌ Вишлист не найден. Возможно, ссылка устарела.",
              reply_markup: {
                inline_keyboard: [
                  [
                  {
                    text: "📋 Создать вишлист",
                    web_app: { url: web_app_url }
                  }
                  ]
                ]
              }
            )
          end
        else
          # Обычное приветствие - создаем или обновляем пользователя
          begin
            user = User.find_or_create_by(telegram_id: message.from.id) do |u|
              u.username = message.from.username
              u.first_name = message.from.first_name
              u.last_name = message.from.last_name
            end
            
            # Обновляем данные если они изменились
            user.update(
              username: message.from.username,
              first_name: message.from.first_name,
              last_name: message.from.last_name
            )
          rescue => e
            puts "Ошибка при создании пользователя: #{e.message}"
            # Продолжаем работу даже если не удалось создать пользователя
          end
          
          welcome_text = "👋 *Привет, #{message.from.first_name}!*\n\n"
          welcome_text += "🎉 Я бот для управления вишлистами!\n\n"
          welcome_text += "✨ *Что я умею:*\n"
          welcome_text += "• Напоминать о предстоящих событиях\n"
          welcome_text += "• Показывать вишлисты по ссылке\n"
          welcome_text += "• Помогать не забыть о важных датах\n\n"
          welcome_text += "💡 *Совет:* Все вишлисты создаются и управляются через удобную *миниапп*!\n"
          welcome_text += "Там вы можете:\n"
          welcome_text += "• Создавать вишлисты с датами\n"
          welcome_text += "• Добавлять подарки с фото и ссылками\n"
          welcome_text += "• Делиться вишлистами с друзьями\n\n"
          welcome_text += "🚀 Откройте миниапп и начните создавать свои вишлисты!"

          bot.api.send_message(
            chat_id: message.chat.id,
            text: welcome_text,
            parse_mode: 'Markdown',
            reply_markup: {
              inline_keyboard: [
                [
                  {
                    text: "🚀 Открыть миниапп",
                    web_app: { url: web_app_url(message.from.id) }
                  }
                ],
                [
                  {
                    text: "❓ Помощь",
                    callback_data: "help"
                  }
                ]
              ]
            }
          )
        end
      when '/help'
        help_text = "📖 *Справка по боту*\n\n"
        help_text += "🔹 */start* - начать работу с ботом\n"
        help_text += "🔹 */help* - показать эту справку\n\n"
        help_text += "📱 *Миниапп*\n"
        help_text += "Все вишлисты создаются через миниапп. Там вы можете:\n"
        help_text += "• Создавать вишлисты\n"
        help_text += "• Добавлять подарки\n"
        help_text += "• Делиться ссылками\n\n"
        help_text += "🔔 *Напоминания*\n"
        help_text += "Бот автоматически напоминает о событиях:\n"
        help_text += "• За 7 дней до события\n"
        help_text += "• За 3 дня до события\n"
        help_text += "• В день события\n\n"
        help_text += "🔗 *Поделиться вишлистом*\n"
        help_text += "Используйте кнопку 'Поделиться' в миниаппе, чтобы отправить ссылку друзьям!"

        bot.api.send_message(
          chat_id: message.chat.id,
          text: help_text,
          parse_mode: 'Markdown',
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🚀 Открыть миниапп",
                  web_app: { url: web_app_url }
                }
              ]
            ]
          }
        )
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "🤔 Не понимаю эту команду.\n\nИспользуйте /help для списка команд или откройте миниапп для работы с вишлистами!",
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🚀 Открыть миниапп",
                  web_app: { url: web_app_url }
                }
              ]
            ]
          }
        )
      end
    when Telegram::Bot::Types::CallbackQuery
      case message.data
      when 'help'
        bot.api.answer_callback_query(callback_query_id: message.id)
        bot.api.send_message(
          chat_id: message.from.id,
          text: "📖 Используйте команду /help для получения справки",
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🚀 Открыть миниапп",
                  web_app: { url: web_app_url }
                }
              ]
            ]
          }
        )
      end
    end
  end
end
