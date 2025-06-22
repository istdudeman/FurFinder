// backend_furfinder/routes/settings_routes.js

const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settings_controller'); // Import the settings controller

// Define a POST route for adding a new device.
// This route expects a JSON body with 'deviceType' and 'deviceId'.
// It will call the 'addDevice' function from the settingsController.
router.post('/add-device', settingsController.addDevice);

// You can add other routes here, for example:
// router.get('/devices', settingsController.getDevices); // Route to get all devices

module.exports = router; // Export the router to be used in index.js
