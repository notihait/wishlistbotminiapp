# Wishlist Web App

Веб-приложение (миниапп) для создания вишлистов и управления подарками.

## Установка

1. Установить зависимости:
```bash
npm install
# или
yarn install
```

2. Настроить переменные окружения в `.env`:
```
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/wishlist_web_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=wishlist_web_db
DB_USER=postgres
DB_PASSWORD=postgres
UPLOAD_DIR=./uploads
```

3. Запустить миграции:
```bash
npm run migrate
# или
node scripts/migrate.js
```

4. Запустить сервер:
```bash
npm start
# или для разработки:
npm run dev
```

Приложение будет доступно по адресу: http://localhost:3000

## API Endpoints

### Wishlists
- `GET /api/wishlists` - получить все вишлисты
- `GET /api/wishlists/:id` - получить вишлист по ID
- `POST /api/wishlists` - создать вишлист
- `PUT /api/wishlists/:id` - обновить вишлист
- `DELETE /api/wishlists/:id` - удалить вишлист

### Gifts
- `GET /api/gifts/wishlist/:wishlistId` - получить все подарки вишлиста
- `GET /api/gifts/:id` - получить подарок по ID
- `POST /api/gifts` - создать подарок (с поддержкой загрузки изображения)
- `PUT /api/gifts/:id` - обновить подарок
- `DELETE /api/gifts/:id` - удалить подарок

## Структура БД

- `wishlists` - вишлисты (название, дата события)
- `gifts` - подарки (название, цена, изображение, ссылка, дополнительная информация)

