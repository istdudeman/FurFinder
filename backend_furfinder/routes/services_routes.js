const express = require('express');
const router = express.Router();
const { ShowServices } = require('../controllers/services_controller');

router.get('/:id', ShowServices); 

module.exports = router