const express = require('express');
const router = express.Router();

// test route
router.post('/login', (req, res) => {
    res.json({ message: 'Auth route works' });
});

router.post('/register', (req, res) => {
    res.json({ message: 'Register route works' });
});

module.exports = router;
