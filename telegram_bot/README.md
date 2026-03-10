# Telegram Bot для вишлистов

Ruby телеграм бот для напоминаний о событиях из вишлистов.

## Установка

1. Установить зависимости:
```bash
bundle install
```

2. Настроить переменные окружения в `.env`:
```
TELEGRAM_BOT_TOKEN=your_token_here
DATABASE_URL=postgresql://user:password@localhost:5432/wishlist_bot_db
```

3. Создать базу данных:
```bash
rake db:create
```

4. Запустить миграции:
```bash
rake db:migrate
```

5. Запустить бота:
```bash
ruby bot.rb
```

## Функционал

- Регистрация пользователей через команду `/start`
- Автоматические напоминания о событиях:
  - За 7 дней до события
  - За 3 дня до события
  - В день события

## Структура БД

- `users` - пользователи Telegram
- `wishlists` - вишлисты (связаны с пользователями и веб-приложением через `web_wishlist_id`)

