-- SmartShop Inventory System - Sample Data Insertion Script

USE SmartShopInventory;
GO

-- Insert sample data into Stores
INSERT INTO Stores (StoreName, Location, ManagerName, Phone, Email, OpeningDate)
VALUES
    ('SmartShop Central', 'Downtown, Main St. 123', 'John Smith', '555-1234', 'john.smith@smartshop.com', '2020-01-15'),
    ('SmartShop North', 'North Mall, 45 Pine Ave', 'Emily Johnson', '555-2345', 'emily.johnson@smartshop.com', '2020-03-20'),
    ('SmartShop East', 'East Shopping Center, 78 Oak St', 'Michael Brown', '555-3456', 'michael.brown@smartshop.com', '2020-06-10');

-- Insert sample data into Categories
INSERT INTO Categories (CategoryName, Description)
VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Home Appliances', 'Appliances for home use'),
    ('Furniture', 'Home and office furniture'),
    ('Clothing', 'Apparel and fashion items'),
    ('Sports', 'Sports equipment and accessories');

-- Insert sample data into Suppliers
INSERT INTO Suppliers (SupplierName, ContactName, Phone, Email, Address)
VALUES
    ('TechSupply Inc.', 'David Wilson', '555-7890', 'david@techsupply.com', '123 Tech Blvd, Tech City'),
    ('HomeGoods Co.', 'Sarah Miller', '555-8901', 'sarah@homegoods.com', '456 Home Ave, Home City'),
    ('FurniCraft Ltd.', 'Robert Taylor', '555-9012', 'robert@furnicraft.com', '789 Craft St, Craft City'),
    ('FashionWorld', 'Jennifer Davis', '555-0123', 'jennifer@fashionworld.com', '101 Fashion Rd, Style City'),
    ('SportsMaster', 'Daniel Clark', '555-1234', 'daniel@sportsmaster.com', '202 Sports Way, Active City');

-- Insert sample data into Products
INSERT INTO Products (ProductName, CategoryID, SupplierID, Description, Price, Cost, SKU)
VALUES
    ('Smartphone X', 1, 1, 'Latest smartphone with advanced features', 799.99, 600.00, 'TECH-001'),
    ('Laptop Pro', 1, 1, 'Professional laptop for work and gaming', 1299.99, 950.00, 'TECH-002'),
    ('Wireless Earbuds', 1, 1, 'High-quality wireless earbuds', 149.99, 80.00, 'TECH-003'),
    ('Coffee Maker', 2, 2, 'Automatic coffee maker with timer', 89.99, 45.00, 'HOME-001'),
    ('Microwave Oven', 2, 2, 'Digital microwave with multiple settings', 129.99, 70.00, 'HOME-002'),
    ('Sofa Set', 3, 3, 'Comfortable 3-piece sofa set', 899.99, 600.00, 'FURN-001'),
    ('Office Desk', 3, 3, 'Modern office desk with drawers', 349.99, 200.00, 'FURN-002'),
    ('T-Shirt', 4, 4, 'Cotton t-shirt, various colors', 19.99, 8.00, 'CLOTH-001'),
    ('Jeans', 4, 4, 'Denim jeans, various sizes', 49.99, 25.00, 'CLOTH-002'),
    ('Basketball', 5, 5, 'Official size basketball', 29.99, 15.00, 'SPORT-001'),
    ('Yoga Mat', 5, 5, 'Non-slip yoga mat', 24.99, 10.00, 'SPORT-002');

-- Insert sample data into Inventory
INSERT INTO Inventory (ProductID, StoreID, StockLevel, LastUpdated, MinStockLevel, MaxStockLevel)
VALUES
    (1, 1, 25, GETDATE(), 10, 50),
    (1, 2, 15, GETDATE(), 10, 50),
    (1, 3, 5, GETDATE(), 10, 50),  -- Low stock level
    (2, 1, 10, GETDATE(), 5, 30),
    (2, 2, 8, GETDATE(), 5, 30),
    (2, 3, 12, GETDATE(), 5, 30),
    (3, 1, 30, GETDATE(), 15, 60),
    (3, 2, 25, GETDATE(), 15, 60),
    (3, 3, 20, GETDATE(), 15, 60),
    (4, 1, 20, GETDATE(), 10, 40),
    (4, 2, 15, GETDATE(), 10, 40),
    (4, 3, 10, GETDATE(), 10, 40),
    (5, 1, 15, GETDATE(), 8, 30),
    (5, 2, 10, GETDATE(), 8, 30),
    (5, 3, 5, GETDATE(), 8, 30),  -- Low stock level
    (6, 1, 8, GETDATE(), 5, 15),
    (6, 2, 6, GETDATE(), 5, 15),
    (6, 3, 4, GETDATE(), 5, 15),  -- Low stock level
    (7, 1, 12, GETDATE(), 6, 20),
    (7, 2, 10, GETDATE(), 6, 20),
    (7, 3, 8, GETDATE(), 6, 20),
    (8, 1, 50, GETDATE(), 30, 100),
    (8, 2, 45, GETDATE(), 30, 100),
    (8, 3, 40, GETDATE(), 30, 100),
    (9, 1, 35, GETDATE(), 20, 80),
    (9, 2, 30, GETDATE(), 20, 80),
    (9, 3, 25, GETDATE(), 20, 80),
    (10, 1, 20, GETDATE(), 10, 40),
    (10, 2, 18, GETDATE(), 10, 40),
    (10, 3, 15, GETDATE(), 10, 40),
    (11, 1, 25, GETDATE(), 15, 50),
    (11, 2, 20, GETDATE(), 15, 50),
    (11, 3, 15, GETDATE(), 15, 50);

-- Insert sample data into Sales
INSERT INTO Sales (StoreID, SaleDate, TotalAmount)
VALUES
    (1, '2023-01-15 10:30:00', 1049.98),
    (1, '2023-01-15 14:45:00', 149.99),
    (2, '2023-01-15 11:20:00', 899.99),
    (2, '2023-01-15 16:10:00', 219.98),
    (3, '2023-01-15 09:15:00', 1299.99),
    (3, '2023-01-15 13:40:00', 74.98),
    (1, '2023-01-16 10:15:00', 379.98),
    (2, '2023-01-16 12:30:00', 129.99),
    (3, '2023-01-16 15:45:00', 349.99);

-- Insert sample data into SaleDetails
INSERT INTO SaleDetails (SaleID, ProductID, Quantity, UnitPrice, Discount)
VALUES
    (1, 1, 1, 799.99, 0),
    (1, 3, 1, 149.99, 0),
    (2, 3, 1, 149.99, 0),
    (3, 6, 1, 899.99, 0),
    (4, 8, 2, 19.99, 0),
    (4, 10, 1, 29.99, 0),
    (4, 11, 1, 24.99, 0),
    (5, 2, 1, 1299.99, 0),
    (6, 8, 2, 19.99, 0),
    (6, 11, 1, 24.99, 0),
    (7, 4, 1, 89.99, 0),
    (7, 5, 1, 129.99, 0),
    (7, 10, 1, 29.99, 0),
    (7, 11, 1, 24.99, 0),
    (8, 5, 1, 129.99, 0),
    (9, 7, 1, 349.99, 0);