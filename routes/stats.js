const express = require('express');
const router = express.Router();

router.get('/dashboard', (req, res) => {
    res.json({ message: 'Stats dashboard OK' });
});

module.exports = router;
