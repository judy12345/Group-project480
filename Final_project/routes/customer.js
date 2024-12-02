const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all customers
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM Customer'); // ��ѯ���пͻ�
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add a new customer
router.post('/', async (req, res) => {
    // ���������л�ȡ�ֶ�
    const { first_name, last_name, email, phone, address } = req.body;

    try {
        const [result] = await db.query(
            'INSERT INTO Customer (First_Name, Last_Name, Email, Phone, Address) VALUES (?, ?, ?, ?, ?)',
            [first_name, last_name, email, phone, address]
        );
        res.json({ message: 'Customer added successfully', id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
