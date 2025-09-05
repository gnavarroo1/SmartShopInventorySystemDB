-- SmartShop Inventory System - Aggregation Queries for Supplier Reports

USE SmartShopInventory;
GO

-- 1. Consulta para identificar proveedores con mejor rendimiento basado en stock entregado
SELECT 
    s.SupplierName,
    COUNT(DISTINCT p.ProductID) AS NumberOfProducts,
    SUM(i.StockLevel) AS TotalStockDelivered
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    s.SupplierName
ORDER BY 
    TotalStockDelivered DESC;

-- 2. Consulta para calcular el valor total de inventario por proveedor
SELECT 
    s.SupplierName,
    SUM(i.StockLevel * p.Price) AS TotalInventoryValue,
    SUM(i.StockLevel * p.Cost) AS TotalInventoryCost,
    SUM(i.StockLevel * (p.Price - p.Cost)) AS PotentialProfit
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    s.SupplierName
ORDER BY 
    TotalInventoryValue DESC;

-- 3. Consulta para analizar la diversidad de categorías por proveedor
-- Usando una subconsulta para emular STRING_AGG con DISTINCT en SQL Server 2019+
SELECT 
    s.SupplierName,
    COUNT(DISTINCT p.CategoryID) AS NumberOfCategories,
    STRING_AGG(CategoryName, ', ') WITHIN GROUP (ORDER BY CategoryName) AS Categories
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN (
        SELECT DISTINCT p.SupplierID, c.CategoryName
        FROM Products p
        JOIN Categories c ON p.CategoryID = c.CategoryID
    ) AS DistinctCategories ON s.SupplierID = DistinctCategories.SupplierID
GROUP BY 
    s.SupplierName
ORDER BY 
    NumberOfCategories DESC;

-- 4. Consulta para identificar proveedores con productos de bajo stock
SELECT 
    s.SupplierName,
    COUNT(DISTINCT CASE WHEN i.StockLevel < i.MinStockLevel THEN p.ProductID END) AS LowStockProducts,
    COUNT(DISTINCT p.ProductID) AS TotalProducts,
    CAST(COUNT(DISTINCT CASE WHEN i.StockLevel < i.MinStockLevel THEN p.ProductID END) AS FLOAT) / 
    COUNT(DISTINCT p.ProductID) * 100 AS LowStockPercentage
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    s.SupplierName
HAVING 
    COUNT(DISTINCT CASE WHEN i.StockLevel < i.MinStockLevel THEN p.ProductID END) > 0
ORDER BY 
    LowStockPercentage DESC;

-- 5. Consulta para calcular el precio promedio, mínimo y máximo de productos por proveedor
SELECT 
    s.SupplierName,
    AVG(p.Price) AS AveragePrice,
    MIN(p.Price) AS MinPrice,
    MAX(p.Price) AS MaxPrice,
    COUNT(p.ProductID) AS NumberOfProducts
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY 
    s.SupplierName
ORDER BY 
    AveragePrice DESC;

-- 6. Consulta para analizar el margen de beneficio promedio por proveedor
SELECT 
    s.SupplierName,
    AVG((p.Price - p.Cost) / p.Price * 100) AS AverageProfitMarginPercentage,
    SUM((p.Price - p.Cost) * i.StockLevel) AS TotalPotentialProfit
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    s.SupplierName
ORDER BY 
    AverageProfitMarginPercentage DESC;