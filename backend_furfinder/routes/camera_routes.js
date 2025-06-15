const express = require('express');
const router = express.Router();

const { streamCamera } = require('../controllers/camera_controller');

router.get('/:animal_id', streamCamera);

module.exports = router;