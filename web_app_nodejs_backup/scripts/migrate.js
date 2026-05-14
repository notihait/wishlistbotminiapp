const pool = require('../config/database');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  const migrationsDir = path.join(__dirname, '../db/migrations');
  const files = fs.readdirSync(migrationsDir).sort();

  try {
    await pool.query('BEGIN');

    for (const file of files) {
      if (file.endsWith('.sql')) {
        const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
        console.log(`Running migration: ${file}`);
        await pool.query(sql);
      }
    }

    await pool.query('COMMIT');
    console.log('All migrations completed successfully');
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

runMigrations();

