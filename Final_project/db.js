// JavaScript source code
//const mysql = require('mysql2');

//// Database connection pool

//const connection = mysql.createConnection({
//    host: 'localhost',   // Corrected host
//    user: 'root',
//    password: 'h19990418',
//    database: 'MarketPlus',
//    port: 3306
//});
//module.exports = pool.promise();

//connection.connect((err) => {
//    if (err) {
//        console.error('Error connecting to MySQL:', err.stack);
//        return;
//    }
//    console.log('Connected to MySQL');
//});
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'h19990418',
    database: 'MarketPlus',
    port: 3306
});

module.exports = pool;
