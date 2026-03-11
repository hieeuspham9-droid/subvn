const express = require("express");
const router = express.Router();
const {
  fetchJapServices,
  fetchJapBalance,
} = require("../services/jap.service");

// GET /api/services/jap
router.get("/jap", async (req, res) => {
  try {
    const data = await fetchJapServices();
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Không lấy được dịch vụ JAP",
      error: err.message,
    });
  }
});

// GET /api/services/jap/balance
router.get("/jap/balance", async (req, res) => {
  try {
    const data = await fetchJapBalance();
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Không lấy được số dư JAP",
      error: err.message,
    });
  }
});

module.exports = router;
