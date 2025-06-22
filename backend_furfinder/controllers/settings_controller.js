const pool = require('../db');

// ✅ Fungsi untuk tambah beacon_id
exports.addBeaconId = async (req, res) => {
  const { beacon_id } = req.body;
  if (!beacon_id) return res.status(400).json({ message: 'beacon_id harus diisi' });

  try {
    // Cari baris yang transmitter_id-nya masih kosong atau beacon_id-nya kosong
    const existing = await pool.query(`
      SELECT * FROM settings 
      WHERE beacon_id IS NULL OR transmitter_id IS NULL 
      LIMIT 1
    `);

    let result;

    if (existing.rows.length > 0 && existing.rows[0].beacon_id == null) {
      // Jika ada baris yang belum punya beacon_id, update
      result = await pool.query(
        `UPDATE settings SET beacon_id = $1 WHERE id = $2 RETURNING *`,
        [beacon_id, existing.rows[0].id]
      );
    } else {
      // Jika tidak ada baris yang bisa diupdate, insert baris baru
      result = await pool.query(
        `INSERT INTO settings (beacon_id) VALUES ($1) RETURNING *`,
        [beacon_id]
      );
    }

    res.status(200).json({
      message: 'Beacon ID berhasil disimpan',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Gagal menyimpan beacon_id:', error);
    res.status(500).json({ message: 'Gagal menyimpan beacon_id', error: error.message });
  }
};

// ✅ Fungsi untuk tambah transmitter_id
exports.addTransmitterId = async (req, res) => {
  const { transmitter_id } = req.body;
  if (!transmitter_id) return res.status(400).json({ message: 'transmitter_id harus diisi' });

  try {
    // Cari baris yang beacon_id-nya masih kosong atau transmitter_id-nya kosong
    const existing = await pool.query(`
      SELECT * FROM settings 
      WHERE beacon_id IS NULL OR transmitter_id IS NULL 
      LIMIT 1
    `);

    let result;

    if (existing.rows.length > 0 && existing.rows[0].transmitter_id == null) {
      // Jika ada baris yang belum punya transmitter_id, update
      result = await pool.query(
        `UPDATE settings SET transmitter_id = $1 WHERE id = $2 RETURNING *`,
        [transmitter_id, existing.rows[0].id]
      );
    } else {
      // Jika tidak ada baris yang bisa diupdate, insert baris baru
      result = await pool.query(
        `INSERT INTO settings (transmitter_id) VALUES ($1) RETURNING *`,
        [transmitter_id]
      );
    }

    res.status(200).json({
      message: 'Transmitter ID berhasil disimpan',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Gagal menyimpan transmitter_id:', error);
    res.status(500).json({ message: 'Gagal menyimpan transmitter_id', error: error.message });
  }
};
