// backend_furfinder/routes/pending_pets_routes.js

const express = require('express');
const router = express.Router();
const { getLatestPendingRFID } = require('../controllers/pending_pets_controller');

router.get('/latest', getLatestPendingRFID);

module.exports = router;