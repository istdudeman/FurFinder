const express = require('express');
const bodyParser = require('body-parser');
const ngrok = require('ngrok');

const app = express();

const userroutes = require('./routes/user_routes');
const petsrouter = require('./routes/pets_routes');
const servicesrouter = require('./routes/services_routes');
const cagerouter = require('./routes/cage_routes');
const bookingsrouter = require('./routes/bookings_router');

app.use(bodyParser.json());

app.use('/api/user', userroutes);
app.use('/api/pets', petsrouter);
app.use('/api/services', servicesrouter);
app.use('/api/cage', cagerouter);
app.use('/api/booking', bookingsrouter);


app.listen(3000, '0.0.0.0', async ()=>{
    console.log('berhasil jalan')

  try {
    const url = await ngrok.connect(3000);
    console.log(`Ngrok tunnel aktif di: ${url}`);
  } catch (err) {
    console.error('Gagal membuka ngrok:', err);
  }
})