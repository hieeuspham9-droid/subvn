const express = require('express');
const router = express.Router();
// Sửa đường dẫn gọi file db.js (Dùng dấu chấm để lùi 1 thư mục ra ngoài)
const db = require('../db'); 

// 1. Route Đăng nhập
router.post('/login', (req, res) => {
    const { username, password } = req.body;
    // Tạm thời để check route, sau này bạn viết code SELECT ở đây
    res.json({ message: 'Auth route works', user: username });
});

// 2. Route Đăng ký (Đã sửa để lưu vào Database)
router.post('/register', (req, res) => {
    const { username, email, phone, password } = req.body;
    const sql = "INSERT INTO users (username, email, phone, password) VALUES (?, ?, ?, ?)";

    // Dùng db.run cho SQLite
    db.run(sql, [username, email, phone, password], function(err) {
        if (err) {
            console.error("❌ Lỗi SQL:", err.message);
            return res.status(500).json({ error: 'Đăng ký thất bại!' });
        }
        res.json({ 
            message: 'Chúc mừng! Bạn đã đăng ký thành công.',
            userId: this.lastID 
        });
    });
});
module.exports = router