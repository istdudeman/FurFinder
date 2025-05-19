const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');

exports.AddBookings = async (req,res) => {
    console.log("Request Body:", req.body);
    const { booking_id, start_date, end_date, status, total_price} = req.body;
  
    try {
      const user_id = 'e993c4f1-b374-4cf9-af7a-c1a683f2f29d';
      const animal_id = '9a70df3a-d86d-4d61-bc21-860afc684bc5';
      const cage_id = '82b635e2-b3cf-46ee-b5ef-dfb28a3e7323';
      const services_id = '1b7790d8-987d-41f9-bb53-5a078c8be1de';
      const result = await pool.query(
        `INSERT INTO bookings (booking_id, start_date, end_date, status, total_price, user_id, animal_id, cage_id, services_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
        [booking_id, start_date, end_date, status, total_price, user_id, animal_id, cage_id, services_id]
      );
  
      res.status(201).json({
        message: 'Booking Berhasil',
        data: result.rows[0]
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Booking Gagal' });
    }
  };