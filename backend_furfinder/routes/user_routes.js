const express = require('express');
const router = express.Router();
const { GetUserProfile} = require('../controllers/user_controller');
const authtoken = require('../userauthtoken')

router.get('/profile/:id', GetUserProfile);

module.exports = router