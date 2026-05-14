const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Настройка multer для загрузки изображений
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = process.env.UPLOAD_DIR || './uploads';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'gift-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Получить все подарки вишлиста
router.get('/wishlist/:wishlistId', async (req, res) => {
  try {
    const { wishlistId } = req.params;
    const result = await pool.query(
      'SELECT * FROM gifts WHERE wishlist_id = $1 ORDER BY created_at DESC',
      [wishlistId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching gifts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Получить подарок по ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM gifts WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Gift not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching gift:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Создать подарок
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const { wishlist_id, name, price, link_url, additional_info } = req.body;
    
    if (!wishlist_id || !name) {
      return res.status(400).json({ error: 'wishlist_id and name are required' });
    }
    
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;
    
    const result = await pool.query(
      `INSERT INTO gifts (wishlist_id, name, price, image_url, link_url, additional_info) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [wishlist_id, name, price || null, imageUrl, link_url || null, additional_info || null]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating gift:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Обновить подарок
router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, link_url, additional_info } = req.body;
    
    let updateQuery = 'UPDATE gifts SET name = $1, price = $2, link_url = $3, additional_info = $4';
    let queryParams = [name, price || null, link_url || null, additional_info || null];
    
    if (req.file) {
      updateQuery += ', image_url = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *';
      queryParams.push(`/uploads/${req.file.filename}`, id);
    } else {
      updateQuery += ', updated_at = CURRENT_TIMESTAMP WHERE id = $5 RETURNING *';
      queryParams.push(id);
    }
    
    const result = await pool.query(updateQuery, queryParams);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Gift not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating gift:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Удалить подарок
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM gifts WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Gift not found' });
    }
    
    res.json({ message: 'Gift deleted successfully' });
  } catch (error) {
    console.error('Error deleting gift:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;

