const axios = require("axios");
const db = require('../config/db');

const JAP_URL = process.env.JAP_API_URL;
const JAP_KEY = process.env.JAP_API_KEY;

// ===== LẤY DỊCH VỤ =====
async function fetchJapServices() {
  const res = await axios.post(
    JAP_URL,
    new URLSearchParams({
      key: JAP_KEY,
      action: "services",
    })
  );
  return res.data;
}

// ===== LẤY SỐ DƯ =====
async function fetchJapBalance() {
  const res = await axios.post(
    JAP_URL,
    new URLSearchParams({
      key: JAP_KEY,
      action: "balance",
    })
  );
  return res.data;
}

// ===== TẠO ĐƠN HÀNG =====
async function createJapOrder({ service, link, quantity }) {
  const res = await axios.post(
    JAP_URL,
    new URLSearchParams({
      key: JAP_KEY,
      action: "add",
      service,
      link,
      quantity
    })
  );

  if (res.data.error) {
    throw new Error(res.data.error);
  }

  return res.data;
}

// ===== SYNC DỊCH VỤ VỀ DB =====
async function syncJapServicesToDB() {
  const services = await fetchJapServices();

  return new Promise((resolve, reject) => {
    db.serialize(() => {
      const stmt = db.prepare(`
        INSERT OR REPLACE INTO services
        (jap_service_id, name, category, rate, min, max, refill, cancel)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `);

      for (const s of services) {
        stmt.run(
          s.service,
          s.name,
          s.category,
          s.rate,
          s.min,
          s.max,
          s.refill ? 1 : 0,
          s.cancel ? 1 : 0
        );
      }

      stmt.finalize();
      resolve({ success: true, total: services.length });
    });
  });
}

// ===== EXPORT ĐẦY ĐỦ =====
module.exports = {
  fetchJapServices,
  fetchJapBalance,
  syncJapServicesToDB,
  createJapOrder
};
