// backend_furfinder/index.js

const express = require('express');
const bodyParser = require('body-parser');
const ngrok = require('ngrok');

const app = express();

const userroutes = require('./routes/user_routes');
const petsrouter = require('./routes/pets_routes');
const servicesrouter = require('./routes/services_routes');
const cagerouter = require('./routes/cage_routes');
const bookingsrouter = require('./routes/bookings_router');
const cameraRouter = require('./routes/camera_routes');
const settingsRouter = require('./routes/settings_routes');
const pendingPetsRouter = require('./routes/pending_pets_routes'); // Import the new pending pets router


app.use(bodyParser.json());

app.use('/api/user', userroutes);
app.use('/api/pets', petsrouter);
app.use('/api/services', servicesrouter);
app.use('/api/cage', cagerouter);
app.use('/api/booking', bookingsrouter);
app.use('/api/camera', cameraRouter);
app.use('/api/settings', settingsRouter);
app.use('/api/pending-pets', pendingPetsRouter); // Use the new pending pets router

app.listen(3000, '0.0.0.0', async () => {
  console.log('berhasil jalan')

  try {
    const url = await ngrok.connect(3000);
    console.log(`Ngrok tunnel aktif di: ${url}`);
  } catch (err) {
    console.error('Gagal membuka ngrok:', err);
  }
})