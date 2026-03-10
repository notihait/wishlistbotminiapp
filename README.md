# Wishlist Mini App

Проект состоит из двух частей:
- **Telegram Bot** (Ruby) - для напоминаний о датах событий
- **Web App** - миниапп для создания вишлистов и управления подарками

## Структура проекта

```
wlmini/
├── telegram_bot/     # Ruby телеграм бот
├── web_app/          # Веб-приложение (миниапп)
└── README.md
```

## Базы данных

- `wishlist_bot_db` - база данных для телеграм бота
- `wishlist_web_db` - база данных для веб-приложения

## Настройка

### Telegram Bot
1. Перейти в `telegram_bot/`
2. Установить зависимости: `bundle install`
3. Настроить БД в `config/database.yml`
4. Запустить миграции: `rake db:migrate`
5. Запустить бота: `ruby bot.rb`

### Web App
1. Перейти в `web_app/`
2. Установить зависимости: `npm install` или `yarn install`
3. Настроить БД в `.env`
4. Запустить миграции
5. Запустить сервер: `npm start` или `yarn start`

## Тестирование

Проект полностью покрыт тестами:
- **Telegram Bot**: RSpec тесты для моделей и сервисов
- **Web App**: Jest тесты для API endpoints и интеграционные тесты

Подробные инструкции по запуску тестов см. в [TESTING.md](TESTING.md)

### Быстрый запуск тестов

**Telegram Bot:**
```bash
cd telegram_bot
bundle install
rake db:test:create db:test:migrate
bundle exec rspec
```

**Web App:**
```bash
cd web_app
npm install
npm test
```

# wishlistbotminiapp
