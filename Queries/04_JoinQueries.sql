-- SmartShop Inventory System - JOIN Queries for Sales Analysis

USE SmartShopInventory;
GO

-- 1. Consulta para mostrar detalles de ventas con información de productos y tiendas
-- Muestra ProductName, SaleDate, StoreLocation y UnitsSold
SELECT 
    p.ProductName,
    s.SaleDate,
    st.Location AS StoreLocation,
    sd.Quantity AS UnitsSold
FROM 
    SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    JOIN Sales s ON sd.SaleID = s.SaleID
    JOIN Stores st ON s.StoreID = st.StoreID
ORDER BY 
    s.SaleDate, p.ProductName;

-- 2. Consulta para analizar ventas por categoría de producto
SELECT 
    c.CategoryName,
    SUM(sd.Quantity) AS TotalUnitsSold,
    SUM(sd.Quantity * sd.UnitPrice) AS TotalSalesAmount
FROM 
    SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY 
    c.CategoryName
ORDER BY 
    TotalSalesAmount DESC;

-- 3. Consulta para analizar ventas por tienda
SELECT 
    st.StoreName,
    st.Location,
    COUNT(DISTINCT s.SaleID) AS NumberOfSales,
    SUM(s.TotalAmount) AS TotalSalesAmount
FROM 
    Sales s
    JOIN Stores st ON s.StoreID = st.StoreID
GROUP BY 
    st.StoreName, st.Location
ORDER BY 
    TotalSalesAmount DESC;

-- 4. Consulta para analizar ventas por fecha
SELECT 
    CONVERT(DATE, s.SaleDate) AS SaleDay,
    COUNT(DISTINCT s.SaleID) AS NumberOfSales,
    SUM(s.TotalAmount) AS TotalSalesAmount
FROM 
    Sales s
GROUP BY 
    CONVERT(DATE, s.SaleDate)
ORDER BY 
    SaleDay;

-- 5. Consulta para analizar productos más vendidos por tienda
SELECT 
    st.StoreName,
    p.ProductName,
    SUM(sd.Quantity) AS TotalUnitsSold
FROM 
    SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    JOIN Sales s ON sd.SaleID = s.SaleID
    JOIN Stores st ON s.StoreID = st.StoreID
GROUP BY 
    st.StoreName, p.ProductName
ORDER BY 
    st.StoreName, TotalUnitsSold DESC;

-- 6. Consulta para analizar ventas por proveedor
SELECT 
    sup.SupplierName,
    SUM(sd.Quantity) AS TotalUnitsSold,
    SUM(sd.Quantity * sd.UnitPrice) AS TotalSalesAmount
FROM 
    SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    JOIN Suppliers sup ON p.SupplierID = sup.SupplierID
GROUP BY 
    sup.SupplierName
ORDER BY 
    TotalSalesAmount DESC;

-- 7. Consulta para analizar margen de beneficio por venta
SELECT 
    s.SaleID,
    s.SaleDate,
    st.StoreName,
    SUM(sd.Quantity * sd.UnitPrice) AS TotalSalesAmount,
    SUM(sd.Quantity * p.Cost) AS TotalCostAmount,
    SUM(sd.Quantity * sd.UnitPrice) - SUM(sd.Quantity * p.Cost) AS ProfitAmount,
    (SUM(sd.Quantity * sd.UnitPrice) - SUM(sd.Quantity * p.Cost)) / SUM(sd.Quantity * sd.UnitPrice) * 100 AS ProfitMarginPercentage
FROM 
    SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    JOIN Sales s ON sd.SaleID = s.SaleID
    JOIN Stores st ON s.StoreID = st.StoreID
GROUP BY 
    s.SaleID, s.SaleDate, st.StoreName
ORDER BY 
    ProfitMarginPercentage DESC;