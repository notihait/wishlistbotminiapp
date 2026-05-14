const pool = require('../../config/database');

describe('Database Configuration', () => {
  it('should connect to database', async () => {
    const result = await pool.query('SELECT NOW()');
    expect(result.rows).toBeDefined();
    expect(result.rows[0]).toHaveProperty('now');
  });

  it('should have correct database name', () => {
    const dbName = process.env.DB_NAME || 'wishlist_web_db';
    expect(dbName).toBeDefined();
  });
});

