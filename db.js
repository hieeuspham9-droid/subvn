const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Kết nối tới file subvn.db
const db = new sqlite3.Database(path.join(__dirname, 'subvn.db'), (err) => {
    if (err) {
        console.error('❌ Lỗi kết nối Database:', err.message);
    } else {
        console.log('✅ Đã kết nối tới SQLite thành công!');
    }
});

module.exports = db;