const request = require('supertest');
const express = require('express');
const wishlistsRouter = require('../../routes/wishlists');
const pool = require('../../config/database');

const app = express();
app.use(express.json());
app.use('/api/wishlists', wishlistsRouter);

describe('Wishlists API', () => {
  beforeEach(async () => {
    await pool.query('TRUNCATE TABLE gifts, wishlists RESTART IDENTITY CASCADE');
  });

  afterAll(async () => {
    await pool.end();
  });

  describe('GET /api/wishlists', () => {
    it('should return empty array when no wishlists exist', async () => {
      const response = await request(app)
        .get('/api/wishlists')
        .expect(200);

      expect(response.body).toEqual([]);
    });

    it('should return all wishlists', async () => {
      // Создаем тестовые вишлисты
      await pool.query(
        "INSERT INTO wishlists (name, event_date) VALUES ('Test 1', '2024-12-25'), ('Test 2', '2024-12-31')"
      );

      const response = await request(app)
        .get('/api/wishlists')
        .expect(200);

      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('name');
      expect(response.body[0]).toHaveProperty('event_date');
    });
  });

  describe('GET /api/wishlists/:id', () => {
    it('should return wishlist by id', async () => {
      const result = await pool.query(
        "INSERT INTO wishlists (name, event_date) VALUES ('Test Wishlist', '2024-12-25') RETURNING id"
      );
      const wishlistId = result.rows[0].id;

      const response = await request(app)
        .get(`/api/wishlists/${wishlistId}`)
        .expect(200);

      expect(response.body.name).toBe('Test Wishlist');
      expect(response.body.event_date).toBe('2024-12-25');
    });

    it('should return 404 for non-existent wishlist', async () => {
      await request(app)
        .get('/api/wishlists/99999')
        .expect(404);
    });
  });

  describe('POST /api/wishlists', () => {
    it('should create a new wishlist', async () => {
      const newWishlist = {
        name: 'New Wishlist',
        event_date: '2024-12-25'
      };

      const response = await request(app)
        .post('/api/wishlists')
        .send(newWishlist)
        .expect(201);

      expect(response.body.name).toBe(newWishlist.name);
      expect(response.body.event_date).toBe(newWishlist.event_date);
      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('created_at');
    });

    it('should return 400 if name is missing', async () => {
      const response = await request(app)
        .post('/api/wishlists')
        .send({ event_date: '2024-12-25' })
        .expect(400);

      expect(response.body.error).toBeDefined();
    });

    it('should return 400 if event_date is missing', async () => {
      const response = await request(app)
        .post('/api/wishlists')
        .send({ name: 'Test' })
        .expect(400);

      expect(response.body.error).toBeDefined();
    });
  });

  describe('PUT /api/wishlists/:id', () => {
    it('should update existing wishlist', async () => {
      const result = await pool.query(
        "INSERT INTO wishlists (name, event_date) VALUES ('Old Name', '2024-12-25') RETURNING id"
      );
      const wishlistId = result.rows[0].id;

      const updatedData = {
        name: 'Updated Name',
        event_date: '2024-12-31'
      };

      const response = await request(app)
        .put(`/api/wishlists/${wishlistId}`)
        .send(updatedData)
        .expect(200);

      expect(response.body.name).toBe(updatedData.name);
      expect(response.body.event_date).toBe(updatedData.event_date);
    });

    it('should return 404 for non-existent wishlist', async () => {
      await request(app)
        .put('/api/wishlists/99999')
        .send({ name: 'Test', event_date: '2024-12-25' })
        .expect(404);
    });
  });

  describe('DELETE /api/wishlists/:id', () => {
    it('should delete wishlist', async () => {
      const result = await pool.query(
        "INSERT INTO wishlists (name, event_date) VALUES ('To Delete', '2024-12-25') RETURNING id"
      );
      const wishlistId = result.rows[0].id;

      await request(app)
        .delete(`/api/wishlists/${wishlistId}`)
        .expect(200);

      // Проверяем, что вишлист удален
      const checkResult = await pool.query('SELECT * FROM wishlists WHERE id = $1', [wishlistId]);
      expect(checkResult.rows).toHaveLength(0);
    });

    it('should return 404 for non-existent wishlist', async () => {
      await request(app)
        .delete('/api/wishlists/99999')
        .expect(404);
    });

    it('should cascade delete gifts when wishlist is deleted', async () => {
      const result = await pool.query(
        "INSERT INTO wishlists (name, event_date) VALUES ('With Gifts', '2024-12-25') RETURNING id"
      );
      const wishlistId = result.rows[0].id;

      await pool.query(
        "INSERT INTO gifts (wishlist_id, name) VALUES ($1, 'Test Gift')",
        [wishlistId]
      );

      await request(app)
        .delete(`/api/wishlists/${wishlistId}`)
        .expect(200);

      // Проверяем, что подарки тоже удалены
      const giftsResult = await pool.query('SELECT * FROM gifts WHERE wishlist_id = $1', [wishlistId]);
      expect(giftsResult.rows).toHaveLength(0);
    });
  });
});

