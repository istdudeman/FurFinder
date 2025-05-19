const express = require('express');
const router = express.Router();
const { AddBookings } = require('../controllers/bookings_controller');

router.post('/addbookings', AddBookings)

module.exports = router;