// backend_furfinder/controllers/pending_pets_controller.js

const pool = require('../db');

exports.getLatestPendingRFID = async (req, res) => {
    try {
        const result = await pool.query(`
      SELECT animal_id, created_at FROM pending_pets
      ORDER BY created_at DESC
      LIMIT 1
    `);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No pending beacon found.' });
        }

        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching latest pending beacon:', error);
        res.status(500).json({ message: 'Failed to fetch latest pending beacon.', error: error.message });
    }
};

// You can add more functions here if needed, e.g., to delete old pending RFIDs
// exports.deleteOldPendingRFIDs = async (req, res) => { ... };