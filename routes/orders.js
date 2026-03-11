// routes/orders.js
const express = require('express');
const router = express.Router();

// THÊM ĐOẠN NÀY ĐỂ TRÌNH DUYỆT (GOOGLE) ĐỌC ĐƯỢC
router.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Bạn đang truy cập đúng vào API Orders!'
    });
});

// Đoạn POST hiện tại của bạn
router.post('/', (req, res) => {
    // ... code xử lý order của bạn ...
});

module.exports = router;