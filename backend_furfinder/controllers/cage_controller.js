const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');

exports.ShowCageInfo = async (req,res) =>{
    const { id } = req.params;

    try 
    {
      const result = await pool.query(
        `SELECT cage_number, status, animal_type, price_per_day, total_price FROM cage WHERE cage_id = $1`,
        [id]
      );
      if(result.rows.length === 0){
        return res.status(404).json({ message: 'Cage tidak ditemukan'})
      }

      const cage = result.rows;
      res.status(200).json(cage);
    }catch (error) {
      console.error(error);
      res.status(500).json({message: 'Terjadi kesalahan saat mengambil data cage'})
    }
};