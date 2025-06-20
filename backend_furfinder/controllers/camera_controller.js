const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');
const http = require('http');
const https = require('https');
const { URL } = require('url');

exports.streamCamera = async (req, res) => {
  const { animal_id } = req.params;
  console.log("Received request for animal_id:", animal_id);

  try {
    const result = await pool.query(
      `SELECT url FROM camera WHERE animal_id = $1 LIMIT 1`,
      [animal_id]
    );

    console.log("Database result:", result.rows);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'URL kamera tidak ditemukan untuk animal_id ini' });
    }

    const streamUrl = result.rows[0].url;
    
    // 👉 Kirim URL ke frontend (Flutter)
    return res.status(200).json({ url: streamUrl });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Gagal mengambil URL kamera dari database' });
  }
}
