// JavaScript source code
const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all transactions
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM Transaction');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add a transaction
router.post('/', async (req, res) => {
    const { Customer_ID, Date, Total_Amount } = req.body;
    try {
        const [result] = await db.query(
            'INSERT INTO Transaction (Customer_ID, Date, Total_Amount) VALUES (?, ?, ?)',
            [Customer_ID, Date, Total_Amount]
        );
        res.json({ message: 'Transaction added successfully', id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

