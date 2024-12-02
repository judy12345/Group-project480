const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all products
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM Product');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Search products (fuzzy query by name or UPC)
router.get('/search/:query', async (req, res) => {
    const { query } = req.params;
    try {
        const [rows] = await db.query(
            'SELECT UPC_Code, Product_Name, Price FROM Product WHERE Product_Name LIKE ? OR UPC_Code LIKE ?',
            [`%${query}%`, `%${query}%`]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add a new product
router.post('/', async (req, res) => {
    const { UPC_Code, Product_Name, Price, Size, Weight, Characteristics } = req.body;
    if (!UPC_Code || !Product_Name || !Price) {
        return res.status(400).json({ error: 'UPC_Code, Product_Name, and Price are required' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO Product (UPC_Code, Product_Name, Price, Size, Weight, Characteristics) VALUES (?, ?, ?, ?, ?, ?)',
            [UPC_Code, Product_Name, Price, Size || null, Weight || null, Characteristics || null]
        );
        res.json({ message: 'Product added successfully', id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update a product
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { Product_Name, Price, Size, Weight, Characteristics } = req.body;

    try {
        await db.query(
            'UPDATE Product SET Product_Name = ?, Price = ?, Size = ?, Weight = ?, Characteristics = ? WHERE UPC_Code = ?',
            [Product_Name, Price, Size || null, Weight || null, Characteristics || null, id]
        );
        res.json({ message: 'Product updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Delete a product
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM Product WHERE UPC_Code = ?', [id]);
        res.json({ message: 'Product deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
