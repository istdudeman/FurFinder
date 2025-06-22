// backend_furfinder/routes/settings_routes.js

const express = require('express');
const router = express.Router();
const { addBeaconId, addTransmitterId } = require('../controllers/settings_controller'); // Import the settings controller
 // Import the settings controller

router.post('/addbeacon', addBeaconId);
router.post('/addtransmitter', addTransmitterId); // Route to add transmitter ID
 // Route to add device settings
 // Route to add device settings

// You can add other routes here, for example:
// router.get('/devices', settingsController.getDevices); // Route to get all devices

module.exports = router; // Export the router to be used in index.js
