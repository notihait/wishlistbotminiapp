const request = require('supertest');
const express = require('express');
const giftsRouter = require('../../routes/gifts');
const pool = require('../../config/database');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(express.json());
app.use('/api/gifts', giftsRouter);

describe('Gifts API', () => {
  let wishlistId;

  beforeEach(async () => {
    await pool.query('TRUNCATE TABLE gifts, wishlists RESTART IDENTITY CASCADE');
    const result = await pool.query(
      "INSERT INTO wishlists (name, event_date) VALUES ('Test Wishlist', '2024-12-25') RETURNING id"
    );
    wishlistId = result.rows[0].id;
  });

  afterAll(async () => {
    await pool.end();
  });

  describe('GET /api/gifts/wishlist/:wishlistId', () => {
    it('should return empty array when no gifts exist', async () => {
      const response = await request(app)
        .get(`/api/gifts/wishlist/${wishlistId}`)
        .expect(200);

      expect(response.body).toEqual([]);
    });

    it('should return all gifts for a wishlist', async () => {
      await pool.query(
        "INSERT INTO gifts (wishlist_id, name, price) VALUES ($1, 'Gift 1', 100), ($1, 'Gift 2', 200)",
        [wishlistId]
      );

      const response = await request(app)
        .get(`/api/gifts/wishlist/${wishlistId}`)
        .expect(200);

      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('name');
      expect(response.body[0]).toHaveProperty('price');
    });
  });

  describe('GET /api/gifts/:id', () => {
    it('should return gift by id', async () => {
      const result = await pool.query(
        "INSERT INTO gifts (wishlist_id, name, price) VALUES ($1, 'Test Gift', 150) RETURNING id",
        [wishlistId]
      );
      const giftId = result.rows[0].id;

      const response = await request(app)
        .get(`/api/gifts/${giftId}`)
        .expect(200);

      expect(response.body.name).toBe('Test Gift');
      expect(response.body.price).toBe('150.00');
    });

    it('should return 404 for non-existent gift', async () => {
      await request(app)
        .get('/api/gifts/99999')
        .expect(404);
    });
  });

  describe('POST /api/gifts', () => {
    it('should create a new gift without image', async () => {
      const newGift = {
        wishlist_id: wishlistId,
        name: 'New Gift',
        price: 99.99,
        link_url: 'https://example.com',
        additional_info: 'Some info'
      };

      const response = await request(app)
        .post('/api/gifts')
        .send(newGift)
        .expect(201);

      expect(response.body.name).toBe(newGift.name);
      expect(response.body.price).toBe(newGift.price.toString());
      expect(response.body.link_url).toBe(newGift.link_url);
      expect(response.body.additional_info).toBe(newGift.additional_info);
      expect(response.body).toHaveProperty('id');
    });

    it('should create a new gift with image', async () => {
      // Создаем тестовый файл изображения
      const testImagePath = path.join(__dirname, '../fixtures/test-image.jpg');
      const uploadDir = process.env.UPLOAD_DIR || './uploads';
      
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }

      // Создаем простой тестовый файл
      fs.writeFileSync(testImagePath, Buffer.from('fake image data'));

      const response = await request(app)
        .post('/api/gifts')
        .field('wishlist_id', wishlistId)
        .field('name', 'Gift with Image')
        .field('price', '50')
        .attach('image', testImagePath)
        .expect(201);

      expect(response.body.name).toBe('Gift with Image');
      expect(response.body.image_url).toBeDefined();
      expect(response.body.image_url).toContain('/uploads/');

      // Очистка
      if (fs.existsSync(testImagePath)) {
        fs.unlinkSync(testImagePath);
      }
    });

    it('should return 400 if wishlist_id is missing', async () => {
      const response = await request(app)
        .post('/api/gifts')
        .send({ name: 'Test Gift' })
        .expect(400);

      expect(response.body.error).toBeDefined();
    });

    it('should return 400 if name is missing', async () => {
      const response = await request(app)
        .post('/api/gifts')
        .send({ wishlist_id: wishlistId })
        .expect(400);

      expect(response.body.error).toBeDefined();
    });
  });

  describe('PUT /api/gifts/:id', () => {
    it('should update existing gift', async () => {
      const result = await pool.query(
        "INSERT INTO gifts (wishlist_id, name, price) VALUES ($1, 'Old Name', 100) RETURNING id",
        [wishlistId]
      );
      const giftId = result.rows[0].id;

      const updatedData = {
        name: 'Updated Name',
        price: 200,
        link_url: 'https://updated.com'
      };

      const response = await request(app)
        .put(`/api/gifts/${giftId}`)
        .send(updatedData)
        .expect(200);

      expect(response.body.name).toBe(updatedData.name);
      expect(parseFloat(response.body.price)).toBe(updatedData.price);
      expect(response.body.link_url).toBe(updatedData.link_url);
    });

    it('should return 404 for non-existent gift', async () => {
      await request(app)
        .put('/api/gifts/99999')
        .send({ name: 'Test', wishlist_id: wishlistId })
        .expect(404);
    });
  });

  describe('DELETE /api/gifts/:id', () => {
    it('should delete gift', async () => {
      const result = await pool.query(
        "INSERT INTO gifts (wishlist_id, name) VALUES ($1, 'To Delete') RETURNING id",
        [wishlistId]
      );
      const giftId = result.rows[0].id;

      await request(app)
        .delete(`/api/gifts/${giftId}`)
        .expect(200);

      // Проверяем, что подарок удален
      const checkResult = await pool.query('SELECT * FROM gifts WHERE id = $1', [giftId]);
      expect(checkResult.rows).toHaveLength(0);
    });

    it('should return 404 for non-existent gift', async () => {
      await request(app)
        .delete('/api/gifts/99999')
        .expect(404);
    });
  });
});

