const pool = require('../supabase');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');

exports.ShowCage = async (req,res) =>{

    try 
    {
      const result = await pool.query(
        `SELECT * FROM cage`,
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