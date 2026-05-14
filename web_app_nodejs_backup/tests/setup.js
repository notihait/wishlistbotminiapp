// Используем тестовую БД
process.env.DB_NAME = process.env.DB_NAME || 'wishlist_web_test_db';
process.env.NODE_ENV = 'test';

// Настройка timeout для тестов
jest.setTimeout(10000);

