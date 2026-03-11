const express = require('express');
const router = express.Router();
const db = require('../config/db'); //

// 1. Route tạo đơn hàng (Dùng POST)
router.post('/orders', async (req, res) => {
    try {
        const { service, link, quantity } = req.body;
        let status = 'Pending';
        let result = null;

        try {
            // Gọi API thực tế
            result = await createJapOrder({ service, link, quantity });
            status = 'Success';
        } catch (apiErr) {
            // Nếu lỗi (như hết tiền), vẫn ghi nhận vào DB để test
            status = 'Failed: ' + apiErr.message;
        }

        const query = `INSERT INTO orders (service_id, link, quantity, status) VALUES (?, ?, ?, ?)`;
        db.run(query, [service, link, quantity, status], function(err) {
            if (err) return res.status(500).json({ success: false, message: err.message });
            
            res.json({
                success: true,
                db_id: this.lastID,
                api_status: status,
                data: result
            });
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// 2. Route xem lịch sử (Dùng GET) -
router.get('/history', (req, res) => {
    db.all("SELECT * FROM orders ORDER BY id DESC LIMIT 10", [], (err, rows) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        res.json({ success: true, orders: rows });
    });
});

module.exports = router;

router.get('/services', async (req, res) => {
    try {
        // Đây là nơi bạn gọi API của JAP để lấy danh sách dịch vụ về
        const { getJapServices } = require('../services/jap.service');
        const services = await getJapServices();
        res.json({ success: true, services: services });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});
module.exports = router;