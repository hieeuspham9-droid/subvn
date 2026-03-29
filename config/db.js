
const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'subvn.db');

let db;

try {
  db = new Database(dbPath);
  console.log('✅ SQLite (better-sqlite3) connected');
} catch (err) {
  console.error('❌ DB connection error', err);
}

module.exports = db;