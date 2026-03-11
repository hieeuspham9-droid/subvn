const express = require('express');
const router = express.Router();

router.get('/users', (req, res) => {
    res.json({ message: 'Admin users OK' });
});

module.exports = router;
