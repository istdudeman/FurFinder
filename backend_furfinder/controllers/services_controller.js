const pool = require('../db');
const jwt = require('jsonwebtoken');
const { message } = require('statuses');

exports.ShowServices = async (req,res) =>{

    try 
    {
      const result = await pool.query(
        `SELECT * FROM services`,
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