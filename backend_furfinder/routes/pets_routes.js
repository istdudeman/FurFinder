const express = require('express');
const router = express.Router();
const { ShowPetData, Addpets } = require('../controllers/pets_controller')

router.post('/add', Addpets);

router.get('/:id', ShowPetData);



module.exports = router
