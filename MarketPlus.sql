
CREATE DATABASE MarketPlus;
USE MarketPlus;

-- # Create tables: Product, Customer, Store
CREATE TABLE Store (
    Store_ID INT AUTO_INCREMENT PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    Hours_of_Operation VARCHAR(100)
);
-- # Create tables: Product, Customer, Store
CREATE TABLE Product (
    UPC_Code VARCHAR(15) PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Size VARCHAR(50),
    Weight DECIMAL(10, 2),
    Characteristics TEXT,
    Price DECIMAL(10, 2)
);

-- # Create tables: Brand, Product_Brand
CREATE TABLE Brand (
    Brand_ID INT AUTO_INCREMENT PRIMARY KEY,
    Brand_Name VARCHAR(100) NOT NULL
);
-- # Create tables: Product_Type, Product_Product_Type
CREATE TABLE Product_Type (
    Product_Type_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL
);

-- # Create tables: Vendor, Product_Vendor
CREATE TABLE Vendor (
    Vendor_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vendor_Name VARCHAR(100) NOT NULL,
    Contact_Details TEXT
);

-- # Create tables: Customer, Customer_Store
CREATE TABLE Customer (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact_Info TEXT
);

-- # Create tables: Transaction, Transaction_Product
CREATE TABLE Transaction (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    Total_Amount DECIMAL(10, 2) NOT NULL,
    Customer_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- # Create tables: Inventory, Inventory_Product
CREATE TABLE Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Quantity INT NOT NULL,
    Reorder_Level INT NOT NULL,
    Price DECIMAL(10, 2),
    Store_ID INT,
    Product_UPC VARCHAR(15),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code)
);

CREATE TABLE Purchase_Details (
    Purchase_Details_ID INT AUTO_INCREMENT PRIMARY KEY,
    Transaction_ID INT,
    Product_UPC VARCHAR(15),
    Unit_Price DECIMAL(10, 2),
    Quantity INT NOT NULL,
    FOREIGN KEY (Transaction_ID) REFERENCES Transaction(Transaction_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code)
);

CREATE TABLE Product_Vendor (
    Product_UPC VARCHAR(15),
    Vendor_ID INT,
    PRIMARY KEY (Product_UPC, Vendor_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code),
    FOREIGN KEY (Vendor_ID) REFERENCES Vendor(Vendor_ID)
);

CREATE TABLE Transaction_Product (
    Transaction_ID INT,
    Product_UPC VARCHAR(15),
    PRIMARY KEY (Transaction_ID, Product_UPC),
    FOREIGN KEY (Transaction_ID) REFERENCES Transaction(Transaction_ID),
    FOREIGN KEY (Product_UPC) REFERENCES Product(UPC_Code)
);



