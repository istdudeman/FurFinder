const express = require('express');
const router = express.Router();
const { ShowPetData, Addpets, saveRFID } = require('../controllers/pets_controller')

router.post('/add', Addpets);

router.get('/:id', ShowPetData);

router.post('/rfid', saveRFID); 



module.exports = router
