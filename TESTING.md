# Инструкция по тестированию

## Тестирование Ruby Telegram Bot

### Установка зависимостей

```bash
cd telegram_bot
bundle install
```

### Настройка тестовой базы данных

1. Создать тестовую БД:
```bash
rake db:test:create
```

2. Запустить миграции:
```bash
rake db:test:migrate
```

### Запуск тестов

```bash
# Все тесты
bundle exec rspec

# Или через rake
rake spec
```

### Структура тестов

- `spec/models/` - тесты моделей (User, Wishlist)
- `spec/services/` - тесты сервисов (ReminderService)
- `spec/lib/` - тесты библиотек
- `spec/factories/` - фабрики для тестовых данных

### Покрытие тестами

Тесты покрывают:
- ✅ Валидации моделей
- ✅ Ассоциации между моделями
- ✅ Логику ReminderService
- ✅ Различные сценарии напоминаний

## Тестирование Web App

### Установка зависимостей

```bash
cd web_app
npm install
```

### Настройка тестовой базы данных

1. Создать тестовую БД:
```sql
CREATE DATABASE wishlist_web_test_db;
```

2. Запустить миграции на тестовой БД:
```bash
DB_NAME=wishlist_web_test_db npm run migrate
```

### Запуск тестов

```bash
# Все тесты
npm test

# С покрытием
npm test -- --coverage

# В режиме watch
npm run test:watch
```

### Структура тестов

- `tests/routes/` - тесты API endpoints
- `tests/integration/` - интеграционные тесты
- `tests/config/` - тесты конфигурации

### Покрытие тестами

Тесты покрывают:
- ✅ CRUD операции для вишлистов
- ✅ CRUD операции для подарков
- ✅ Валидацию входных данных
- ✅ Обработку ошибок
- ✅ Каскадное удаление
- ✅ Интеграционные сценарии

## Запуск всех тестов

Из корневой директории проекта:

```bash
# Тесты бота
cd telegram_bot && bundle exec rspec && cd ..

# Тесты веб-приложения
cd web_app && npm test && cd ..
```

## CI/CD

Для автоматического запуска тестов можно добавить в CI/CD pipeline:

```yaml
# Пример для GitHub Actions
- name: Test Ruby Bot
  run: |
    cd telegram_bot
    bundle install
    rake db:test:create db:test:migrate
    bundle exec rspec

- name: Test Web App
  run: |
    cd web_app
    npm install
    npm test
```


