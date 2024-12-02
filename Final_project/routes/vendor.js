// JavaScript source code
const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all vendors
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM Vendor');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add a vendor
router.post('/', async (req, res) => {
    const { Vendor_Name, Contact_Details } = req.body;
    try {
        const [result] = await db.query(
            'INSERT INTO Vendor (Vendor_Name, Contact_Details) VALUES (?, ?)',
            [Vendor_Name, Contact_Details]
        );
        res.json({ message: 'Vendor added successfully', id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
