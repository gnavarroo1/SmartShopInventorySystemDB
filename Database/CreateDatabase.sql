-- SmartShop Inventory System - Database Creation Script

-- Create Database
CREATE DATABASE SmartShopInventory;
GO

-- Use the created database
USE SmartShopInventory;
GO

-- Create Tables

-- Stores Table
CREATE TABLE Stores (
    StoreID INT PRIMARY KEY IDENTITY(1,1),
    StoreName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    ManagerName NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    OpeningDate DATE NOT NULL
);

-- Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(200)
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    SupplierID INT FOREIGN KEY REFERENCES Suppliers(SupplierID),
    Description NVARCHAR(500),
    Price DECIMAL(10, 2) NOT NULL,
    Cost DECIMAL(10, 2) NOT NULL,
    SKU NVARCHAR(50) UNIQUE
);

-- Inventory Table
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    StoreID INT FOREIGN KEY REFERENCES Stores(StoreID),
    StockLevel INT NOT NULL,
    LastUpdated DATETIME DEFAULT GETDATE(),
    MinStockLevel INT DEFAULT 10,
    MaxStockLevel INT DEFAULT 100
);

-- Sales Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    StoreID INT FOREIGN KEY REFERENCES Stores(StoreID),
    SaleDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) NOT NULL
);

-- SaleDetails Table
CREATE TABLE SaleDetails (
    SaleDetailID INT PRIMARY KEY IDENTITY(1,1),
    SaleID INT FOREIGN KEY REFERENCES Sales(SaleID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Discount DECIMAL(5, 2) DEFAULT 0
);

-- Create Indexes for better performance
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_Products_SupplierID ON Products(SupplierID);
CREATE INDEX IX_Inventory_ProductID ON Inventory(ProductID);
CREATE INDEX IX_Inventory_StoreID ON Inventory(StoreID);
CREATE INDEX IX_Inventory_StockLevel ON Inventory(StockLevel);
CREATE INDEX IX_Sales_StoreID ON Sales(StoreID);
CREATE INDEX IX_Sales_SaleDate ON Sales(SaleDate);
CREATE INDEX IX_SaleDetails_SaleID ON SaleDetails(SaleID);
CREATE INDEX IX_SaleDetails_ProductID ON SaleDetails(ProductID);