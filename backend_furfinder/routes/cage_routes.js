const express = require('express');
const router = express.Router();
const { ShowCageInfo } = require('../controllers/cage_controller')

router.get('/:id', ShowCageInfo); 

module.exports = router