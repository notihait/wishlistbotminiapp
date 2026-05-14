const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// Получить все вишлисты
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM wishlists ORDER BY event_date ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching wishlists:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Получить вишлист по ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM wishlists WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Wishlist not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching wishlist:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Создать вишлист
router.post('/', async (req, res) => {
  try {
    const { name, event_date } = req.body;
    
    if (!name || !event_date) {
      return res.status(400).json({ error: 'Name and event_date are required' });
    }
    
    const result = await pool.query(
      'INSERT INTO wishlists (name, event_date) VALUES ($1, $2) RETURNING *',
      [name, event_date]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating wishlist:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Обновить вишлист
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, event_date } = req.body;
    
    const result = await pool.query(
      'UPDATE wishlists SET name = $1, event_date = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      [name, event_date, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Wishlist not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating wishlist:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Удалить вишлист
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM wishlists WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Wishlist not found' });
    }
    
    res.json({ message: 'Wishlist deleted successfully' });
  } catch (error) {
    console.error('Error deleting wishlist:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;

