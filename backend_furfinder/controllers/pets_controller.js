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
          b.start_date,
          b.end_date
        FROM bookings b
        JOIN pets p ON b.animal_id = p.animal_id
        JOIN services s ON b.services_id = s.services_id
        WHERE p.animal_id = $1
        ORDER BY b.start_date DESC`,
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

exports.Addpets = async (req, res) => {
  console.log("Request Body:", req.body);
  let { animal_id, name, breed, age, services, date } = req.body;

  try {
    const user_id = 'e993c4f1-b374-4cf9-af7a-c1a683f2f29d';
    // Jika tidak ada animal_id, ambil RFID terbaru dari pending_pets
    if (!animal_id) {
      const rfidResult = await pool.query(`
        SELECT animal_id FROM pending_pets
        ORDER BY created_at DESC
        LIMIT 1
      `);

      if (rfidResult.rows.length === 0) {
        return res.status(400).json({ message: 'RFID belum tersedia. Silakan scan tag RFID terlebih dahulu.' });
      }

      animal_id = rfidResult.rows[0].animal_id;
    }

    const result = await pool.query(
      `INSERT INTO pets (animal_id, user_id, name, breed, age, services, date)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [animal_id, user_id, name, breed, age, services, date]
    );

    // Hapus dari pending_pets jika sudah dipakai
    await pool.query('DELETE FROM pending_pets WHERE animal_id = $1', [animal_id]);

    res.status(201).json({
      message: 'Hewan peliharaan berhasil ditambahkan',
      data: result.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Gagal menambahkan hewan peliharaan' });
  }
};


exports.saveRFID = async (req, res) => {
  const { rfid } = req.body;
  try {
    await pool.query('INSERT INTO pending_pets (animal_id) VALUES ($1) ON CONFLICT DO NOTHING', [rfid]);
    res.status(201).json({ message: 'RFID saved' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal simpan RFID' });
  }
};
