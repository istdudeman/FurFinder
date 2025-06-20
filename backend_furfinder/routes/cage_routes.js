const express = require('express');
const router = express.Router();
const { ShowCage } = require('../controllers/cage_controller')

router.get('/list', ShowCage); 

module.exports = router