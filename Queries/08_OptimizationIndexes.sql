-- SmartShop Inventory System - Índices para Optimización de Consultas

USE SmartShopInventory;
GO

-- Índices para la tabla Products
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_ProductID' AND object_id = OBJECT_ID('Products'))
CREATE INDEX IX_Products_ProductID ON Products(ProductID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_CategoryID' AND object_id = OBJECT_ID('Products'))
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_SupplierID' AND object_id = OBJECT_ID('Products'))
CREATE INDEX IX_Products_SupplierID ON Products(SupplierID);

-- Índices para la tabla Inventory
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Inventory_ProductID' AND object_id = OBJECT_ID('Inventory'))
CREATE INDEX IX_Inventory_ProductID ON Inventory(ProductID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Inventory_StoreID' AND object_id = OBJECT_ID('Inventory'))
CREATE INDEX IX_Inventory_StoreID ON Inventory(StoreID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Inventory_StockLevel' AND object_id = OBJECT_ID('Inventory'))
CREATE INDEX IX_Inventory_StockLevel ON Inventory(StockLevel);

-- Índices para la tabla Sales
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_SaleDate' AND object_id = OBJECT_ID('Sales'))
CREATE INDEX IX_Sales_SaleDate ON Sales(SaleDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_StoreID' AND object_id = OBJECT_ID('Sales'))
CREATE INDEX IX_Sales_StoreID ON Sales(StoreID);

-- Índices para la tabla SaleDetails
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleDetails_SaleID' AND object_id = OBJECT_ID('SaleDetails'))
CREATE INDEX IX_SaleDetails_SaleID ON SaleDetails(SaleID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleDetails_ProductID' AND object_id = OBJECT_ID('SaleDetails'))
CREATE INDEX IX_SaleDetails_ProductID ON SaleDetails(ProductID);

-- Índices compuestos para consultas frecuentes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleDetails_ProductID_Quantity' AND object_id = OBJECT_ID('SaleDetails'))
CREATE INDEX IX_SaleDetails_ProductID_Quantity ON SaleDetails(ProductID, Quantity);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Inventory_ProductID_StoreID' AND object_id = OBJECT_ID('Inventory'))
CREATE INDEX IX_Inventory_ProductID_StoreID ON Inventory(ProductID, StoreID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_CategoryID_Price' AND object_id = OBJECT_ID('Products'))
CREATE INDEX IX_Products_CategoryID_Price ON Products(CategoryID, Price);

PRINT 'Índices creados o verificados correctamente.';
GO