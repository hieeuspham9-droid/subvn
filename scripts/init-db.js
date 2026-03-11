const db = require('../config/db');

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS services (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jap_service_id INTEGER UNIQUE,
      name TEXT,
      category TEXT,
      rate REAL,
      min INTEGER,
      max INTEGER,
      refill INTEGER,
      cancel INTEGER,
      active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  console.log('✅ services table ready');
});

db.close();
