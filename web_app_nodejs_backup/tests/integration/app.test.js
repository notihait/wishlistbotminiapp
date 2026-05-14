const request = require('supertest');
const app = require('../../server');
const pool = require('../../config/database');

// Отключаем логирование в тестах
process.env.NODE_ENV = 'test';

describe('Application Integration Tests', () => {
  beforeEach(async () => {
    await pool.query('TRUNCATE TABLE gifts, wishlists RESTART IDENTITY CASCADE');
  });

  afterAll(async () => {
    await pool.end();
  });

  describe('Full Wishlist Workflow', () => {
    it('should create wishlist and add gifts', async () => {
      // Создаем вишлист
      const wishlistResponse = await request(app)
        .post('/api/wishlists')
        .send({
          name: 'Birthday Wishlist',
          event_date: '2024-12-25'
        })
        .expect(201);

      const wishlistId = wishlistResponse.body.id;

      // Добавляем подарки
      const gift1Response = await request(app)
        .post('/api/gifts')
        .send({
          wishlist_id: wishlistId,
          name: 'Gift 1',
          price: 100
        })
        .expect(201);

      const gift2Response = await request(app)
        .post('/api/gifts')
        .send({
          wishlist_id: wishlistId,
          name: 'Gift 2',
          price: 200,
          link_url: 'https://example.com'
        })
        .expect(201);

      // Получаем вишлист с подарками
      const giftsResponse = await request(app)
        .get(`/api/gifts/wishlist/${wishlistId}`)
        .expect(200);

      expect(giftsResponse.body).toHaveLength(2);
      expect(giftsResponse.body[0].name).toBe('Gift 1');
      expect(giftsResponse.body[1].name).toBe('Gift 2');

      // Удаляем вишлист (должны удалиться и подарки)
      await request(app)
        .delete(`/api/wishlists/${wishlistId}`)
        .expect(200);

      const finalGiftsResponse = await request(app)
        .get(`/api/gifts/wishlist/${wishlistId}`)
        .expect(200);

      expect(finalGiftsResponse.body).toHaveLength(0);
    });
  });

  describe('Error Handling', () => {
    it('should handle invalid routes', async () => {
      await request(app)
        .get('/api/nonexistent')
        .expect(404);
    });

    it('should handle malformed JSON', async () => {
      await request(app)
        .post('/api/wishlists')
        .send('invalid json')
        .set('Content-Type', 'application/json')
        .expect(400);
    });
  });
});

