const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '..', 'subvn.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ DB connection error', err);
  } else {
    console.log('✅ SQLite connected');
  }
});

module.exports = db;
