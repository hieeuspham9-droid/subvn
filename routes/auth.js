const express = require('express');
const router = express.Router();
const db = require('../db'); // Đảm bảo đường dẫn này đúng với file db.js của bạn

// 1. Route Đăng ký (Đã sửa lỗi undefined req.body)
router.post('/register', (req, res) => {
    // Kiểm tra nếu req.body không tồn tại
    if (!req.body || !req.body.username) {
        return res.status(400).json({ 
            error: "Lỗi: Dữ liệu gửi lên bị trống! Hãy kiểm tra lại server.js đã có app.use(express.json()) chưa." 
        });
    }

    const { username, email, phone, password } = req.body;
    const sql = "INSERT INTO users (username, email, phone, password) VALUES (?, ?, ?, ?)";

    // Dùng db.run cho SQLite
    db.run(sql, [username, email, phone, password], function(err) {
        if (err) {
            console.error("❌ Lỗi SQL:", err.message);
            return res.status(500).json({ error: 'Đăng ký thất bại!', details: err.message });
        }
        res.json({
            message: 'Chúc mừng! Bạn đã đăng ký thành công.',
            userId: this.lastID
        });
    });
});

module.exports = router;