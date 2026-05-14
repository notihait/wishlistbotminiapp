# ✅ Проект успешно настроен!

## Что готово:

- ✅ **Базы данных созданы:**
  - `wishlist_bot_db` - для телеграм бота
  - `wishlist_web_db` - для веб-приложения
  - `wishlist_bot_test_db` - для тестов бота
  - `wishlist_web_test_db` - для тестов веб-приложения

- ✅ **Пароль PostgreSQL установлен:** `postgres`

- ✅ **Миграции выполнены:**
  - Telegram Bot: таблицы `users` и `wishlists` созданы
  - Web App: таблицы `wishlists` и `gifts` созданы

- ✅ **Зависимости установлены:**
  - Ruby gems (bundle install)
  - npm packages (npm install)

- ✅ **Тесты написаны:**
  - RSpec тесты для бота
  - Jest тесты для веб-приложения

## 🚀 Запуск приложений

### Telegram Bot

```bash
cd ~/wlmini/telegram_bot
ruby bot.rb
```

### Web App

```bash
cd ~/wlmini/web_app
npm start
```

Веб-приложение будет доступно на: **http://localhost:3000**

## 📝 Полезные команды

### Проверка БД
```bash
# Список таблиц в БД бота
PGPASSWORD=postgres psql -U postgres -h localhost -d wishlist_bot_db -c "\dt"

# Список таблиц в БД веб-приложения
PGPASSWORD=postgres psql -U postgres -h localhost -d wishlist_web_db -c "\dt"
```

### Запуск тестов
```bash
# Тесты бота
cd ~/wlmini/telegram_bot
bundle exec rspec

# Тесты веб-приложения
cd ~/wlmini/web_app
npm test
```

### Миграции
```bash
# Бот
cd ~/wlmini/telegram_bot
bundle exec rake db:migrate

# Веб-приложение
cd ~/wlmini/web_app
npm run migrate
```

## 🎉 Готово к использованию!

Все настроено и готово к работе. Можно начинать использовать приложения!


