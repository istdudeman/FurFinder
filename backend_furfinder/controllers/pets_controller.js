const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');



exports.ShowPetData = async (req,res) =>{
    const { id } = req.params;

    try 
    {
      const result = await pool.query(
      `SELECT 
         p.name,
         p.breed,
         p.age,
         s.services_name,
         b.date
       FROM bookings b
       JOIN pets p ON b.animal_id = p.animal_id
       JOIN services s ON b.services_id = s.services_id
       WHERE p.animal_id = $1
       ORDER BY b.date DESC`,
      [id]
      );
      if(result.rows.length === 0){
        return res.status(404).json({ message: 'Data hewan tidak ditemukan'})
      }

      const pets = result.rows[0];
      res.status(200).json(pets);
    } catch (error) {
      console.error(error);
      res.status(500).json({message: 'Terjadi kesalahan saat mengambil data hewan'})
    }
};

exports.Addpets = async (req,res) => {
  console.log("Request Body:", req.body);
  const { name, breed, age, services, date} = req.body;

  try {
    const user_id = 'e993c4f1-b374-4cf9-af7a-c1a683f2f29d';
    const result = await pool.query(
      `INSERT INTO pets (name, breed, age, services, date)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, breed, age, services, date]
    );

    res.status(201).json({
      message: 'Hewan peliharaan berhasil ditambahkan',
      data: result.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Gagal menambahkan hewan peliharaan' });
  }
};