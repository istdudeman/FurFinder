const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');

exports.ShowServices = async (req,res) =>{
    const { id } = req.params;

    try 
    {
      const result = await pool.query(
        `SELECT services_name, description, price FROM services WHERE services_id = $1`,
        [id]
      );
      if(result.rows.length === 0){
        return res.status(404).json({ message: 'Services tidak ditemukan'})
      }

      const services = result.rows;
      res.status(200).json(services);
    }catch (error) {
      console.error(error);
      res.status(500).json({message: 'Terjadi kesalahan saat mengambil data services'})
    }
};