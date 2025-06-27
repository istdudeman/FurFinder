const pool = require('../supabase');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const bcrypt = require('bcrypt');
const { message } = require('statuses');

exports.GetUserProfile = async (req, res) => {
    const { id } = req.params;
  
    try {
      const result = await pool.query(
        'SELECT email, name, address, phone_number FROM users WHERE id = $1',
        [id]
      );
      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Pengguna tidak ditemukan.' });
      }
  
      const user = result.rows;
      res.status(200).json(user);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Terjadi kesalahan saat mengambil data pengguna.' });
    }
  };