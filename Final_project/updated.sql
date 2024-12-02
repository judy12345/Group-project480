CREATE DATABASE IF NOT EXISTS MarketPlus;
USE MarketPlus;

-- Drop all existing procedures
DROP PROCEDURE IF EXISTS sp_search_products;
DROP PROCEDURE IF EXISTS sp_create_transaction;
DROP PROCEDURE IF EXISTS sp_add_transaction_product;

-- Drop existing tables
DROP TABLE IF EXISTS Transaction_Product;
DROP TABLE IF EXISTS Purchase_Details;
DROP TABLE IF EXISTS Product_Vendor;
DROP TABLE IF EXISTS Product_Brand;
DROP TABLE IF EXISTS Product_Product_Type;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Transaction;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Store;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Brand;
DROP TABLE IF EXISTS Product_Type;
DROP TABLE IF EXISTS Vendor;


-- Create Store table
CREATE TABLE Store (
    Store_ID INT AUTO_INCREMENT PRIMARY KEY,
    Store_Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Hours_of_Operation VARCHAR(100),
    Phone VARCHAR(20)
);
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    role VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Product table
CREATE TABLE Product (
    UPC_Code VARCHAR(15) PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Size VARCHAR(50),
    Weight DECIMAL(10, 2),
    Characteristics TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Brand table
CREATE TABLE Brand (
    Brand_ID INT AUTO_INCREMENT PRIMARY KEY,
    Brand_Name VARCHAR(100) NOT NULL,
    Contact_Info TEXT,
    UNIQUE (Brand_Name)
);

-- Create Product_Type table
CREATE TABLE Product_Type (
    Product_Type_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL,
    Description TEXT,
    UNIQUE (Category_Name)
);

-- Create Vendor table
CREATE TABLE Vendor (
    Vendor_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vendor_Name VARCHAR(100) NOT NULL,
    Contact_Details TEXT,
    Email VARCHAR(100),
    Phone VARCHAR(20)
);

-- Create Customer table
CREATE TABLE Customer (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address TEXT,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Product_Brand table
CREATE TABLE Product_Brand (
    Product_UPC VARCHAR(15),
    Brand_ID INT,
    PRIMARY KEY (Product_UPC, Brand_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code) ON DELETE CASCADE,
    FOREIGN KEY (Brand_ID) REFERENCES Brand(Brand_ID) ON DELETE CASCADE
);

-- Create Product_Product_Type table
CREATE TABLE Product_Product_Type (
    Product_UPC VARCHAR(15),
    Product_Type_ID INT,
    PRIMARY KEY (Product_UPC, Product_Type_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code) ON DELETE CASCADE,
    FOREIGN KEY (Product_Type_ID) REFERENCES Product_Type(Product_Type_ID) ON DELETE CASCADE
);

-- Create Product_Vendor table
CREATE TABLE Product_Vendor (
    Product_UPC VARCHAR(15),
    Vendor_ID INT,
    Supply_Price DECIMAL(10, 2),
    PRIMARY KEY (Product_UPC, Vendor_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code) ON DELETE CASCADE,
    FOREIGN KEY (Vendor_ID) REFERENCES Vendor(Vendor_ID) ON DELETE CASCADE
);

-- Create Transaction table
CREATE TABLE Transaction (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Total_Amount DECIMAL(10, 2) NOT NULL,
    Customer_ID INT,
    Store_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID)
);

-- Create Transaction_Product table
CREATE TABLE Transaction_Product (
    Transaction_ID INT,
    Product_UPC VARCHAR(15),
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (Transaction_ID, Product_UPC),
    FOREIGN KEY (Transaction_ID) REFERENCES Transaction(Transaction_ID) ON DELETE CASCADE,
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code) ON DELETE CASCADE
);

-- Create Inventory table
CREATE TABLE Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Store_ID INT,
    Product_UPC VARCHAR(15),
    Quantity INT NOT NULL DEFAULT 0,
    Reorder_Level INT NOT NULL DEFAULT 10,
    Last_Restock_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code),
    UNIQUE KEY store_product (Store_ID, Product_UPC)
);

-- Create indexes
CREATE INDEX idx_product_name ON Product(Product_Name);
CREATE INDEX idx_brand_name ON Brand(Brand_Name);
CREATE INDEX idx_category ON Product_Type(Category_Name);
CREATE INDEX idx_customer_email ON Customer(Email);
CREATE INDEX idx_transaction_date ON Transaction(Date);

CREATE OR REPLACE VIEW vw_product_details AS
SELECT 
    p.UPC_Code,
    p.Product_Name,
    p.Size,
    p.Price,
    b.Brand_Name,
    pt.Category_Name as Product_Type,
    i.Quantity as Stock_Level,
    i.Reorder_Level,
    i.Last_Restock_Date
FROM Product p
LEFT JOIN Product_Brand pb ON p.UPC_Code = pb.Product_UPC
LEFT JOIN Brand b ON pb.Brand_ID = b.Brand_ID
LEFT JOIN Product_Product_Type ppt ON p.UPC_Code = ppt.Product_UPC
LEFT JOIN Product_Type pt ON ppt.Product_Type_ID = pt.Product_Type_ID
LEFT JOIN Inventory i ON p.UPC_Code = i.Product_UPC;

-- Drop the existing procedure first
DROP PROCEDURE IF EXISTS sp_search_products;

DELIMITER //

CREATE PROCEDURE sp_search_products(
    IN search_term VARCHAR(100),
    IN category VARCHAR(100),
    IN brand VARCHAR(100),
    IN size_param VARCHAR(50)
)
BEGIN
    SELECT 
        p.UPC_Code,
        p.Product_Name,
        p.Size,
        p.Price,
        b.Brand_Name,
        pt.Category_Name as Product_Type,
        i.Quantity as Stock_Level
    FROM Product p
    LEFT JOIN Product_Brand pb ON p.UPC_Code = pb.Product_UPC
    LEFT JOIN Brand b ON pb.Brand_ID = b.Brand_ID
    LEFT JOIN Product_Product_Type ppt ON p.UPC_Code = ppt.Product_UPC
    LEFT JOIN Product_Type pt ON ppt.Product_Type_ID = pt.Product_Type_ID
    LEFT JOIN Inventory i ON p.UPC_Code = i.Product_UPC
    WHERE 
        (search_term IS NULL OR 
         p.Product_Name LIKE CONCAT('%', search_term, '%')) AND
        (category IS NULL OR 
         pt.Category_Name LIKE CONCAT('%', category, '%')) AND
        (brand IS NULL OR 
         b.Brand_Name LIKE CONCAT('%', brand, '%')) AND
        (size_param IS NULL OR 
         p.Size LIKE CONCAT('%', size_param, '%'));
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_create_transaction(
    IN p_customer_id INT,
    IN p_store_id INT,
    IN p_total_amount DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Transaction (Customer_ID, Store_ID, Total_Amount)
    VALUES (p_customer_id, p_store_id, p_total_amount);
    SELECT LAST_INSERT_ID() as Transaction_ID;
END //

DELIMITER ;


-- Insert stores
INSERT INTO users (username, password, email, role) VALUES
('testuser', 'password123', 'testuser@example.com', 'user'),
('admin', 'adminpass', 'admin@example.com', 'admin');

INSERT INTO Store (Store_Name, Address, Hours_of_Operation, Phone) VALUES
('MarketPlus Mall', '456 Mall Ave', '10:00-22:00', '555-0456');

-- Insert brands
INSERT INTO Brand (Brand_Name) VALUES 
('Levi''s'),
('Hanes'),
('Zara'),
('Nike'),
('Adidas'),
('Patagonia');

-- Insert product types
INSERT INTO Product_Type (Category_Name) VALUES 
('Bottomwear'),
('Topwear'),
('Dress'),
('Outerwear'),
('Footwear');

-- Insert products
INSERT INTO Product (UPC_Code, Product_Name, Size, Price) VALUES
('123456789', 'Blue Jeans', 'Medium', 49.99),
('223456789', 'White T-Shirt', 'Large', 14.99),
('323456789', 'Black Dress', 'Small', 79.99),
('423456789', 'Red Hoodie', 'Large', 59.99),
('523456789', 'Running Shoes', '10', 120.00),
('623456789', 'Winter Jacket', 'Medium', 199.99);

-- Link products to brands
INSERT INTO Product_Brand (Product_UPC, Brand_ID)
SELECT '123456789', Brand_ID FROM Brand WHERE Brand_Name = 'Levi''s'
UNION ALL
SELECT '223456789', Brand_ID FROM Brand WHERE Brand_Name = 'Hanes'
UNION ALL
SELECT '323456789', Brand_ID FROM Brand WHERE Brand_Name = 'Zara'
UNION ALL
SELECT '423456789', Brand_ID FROM Brand WHERE Brand_Name = 'Nike'
UNION ALL
SELECT '523456789', Brand_ID FROM Brand WHERE Brand_Name = 'Adidas'
UNION ALL
SELECT '623456789', Brand_ID FROM Brand WHERE Brand_Name = 'Patagonia';

-- Link products to categories
INSERT INTO Product_Product_Type (Product_UPC, Product_Type_ID)
SELECT '123456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Bottomwear'
UNION ALL
SELECT '223456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Topwear'
UNION ALL
SELECT '323456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Dress'
UNION ALL
SELECT '423456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Outerwear'
UNION ALL
SELECT '523456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Footwear'
UNION ALL
SELECT '623456789', Product_Type_ID FROM Product_Type WHERE Category_Name = 'Outerwear';

-- Initialize inventory for each store
INSERT INTO Inventory (Store_ID, Product_UPC, Quantity, Reorder_Level)
SELECT 1, UPC_Code, 50, 10 FROM Product

-- Test product search
CALL sp_search_products('jeans', NULL, NULL, NULL);

-- View product details
SELECT * FROM vw_product_details;

-- Check inventory
SELECT * FROM Inventory;
