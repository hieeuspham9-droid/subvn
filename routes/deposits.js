const express = require('express');
const router = express.Router();

// Tạo yêu cầu nạp tiền
router.post('/', (req, res) => {
    res.json({ message: 'Deposit created' });
});

// Lịch sử nạp tiền
router.get('/', (req, res) => {
    res.json({ message: 'Deposit history' });
});

module.exports = router;
