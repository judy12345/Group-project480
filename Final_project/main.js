const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

// Import routes
const productRoutes = require('./routes/product');
const customerRoutes = require('./routes/customer');
const transactionRoutes = require('./routes/transaction');
const vendorRoutes = require('./routes/vendor');

// Initialize express app
const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Routes
app.use('/products', productRoutes);
app.use('/customers', customerRoutes);
app.use('/transactions', transactionRoutes);
app.use('/vendors', vendorRoutes);

// Database query endpoint
const db = require('./db'); // Database connection module

app.post('/query', async (req, res) => {
    const { query } = req.body;
    try {
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
app.use((req, res, next) => {
    console.log(`Request Body: ${JSON.stringify(req.body)}`);
    next();
});


// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
