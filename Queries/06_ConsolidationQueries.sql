-- SmartShop Inventory System - Consolidation Queries for Inventory Across Stores

USE SmartShopInventory;
GO

-- 1. Consulta para consolidar niveles de inventario por producto en todas las tiendas
-- Optimizada usando CTEs para mejorar la legibilidad y el rendimiento
WITH ProductCategoryInfo AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryName
    FROM 
        Products p
        JOIN Categories c ON p.CategoryID = c.CategoryID
),
InventoryStats AS (
    SELECT 
        ProductID,
        SUM(StockLevel) AS TotalStockAcrossStores,
        COUNT(DISTINCT StoreID) AS NumberOfStoresWithProduct,
        MIN(StockLevel) AS MinStockLevel,
        MAX(StockLevel) AS MaxStockLevel,
        AVG(StockLevel) AS AvgStockLevel
    FROM 
        Inventory
    GROUP BY 
        ProductID
)
SELECT 
    pc.ProductID,
    pc.ProductName,
    pc.CategoryName,
    ist.TotalStockAcrossStores,
    ist.NumberOfStoresWithProduct,
    ist.MinStockLevel,
    ist.MaxStockLevel,
    ist.AvgStockLevel
FROM 
    ProductCategoryInfo pc
    JOIN InventoryStats ist ON pc.ProductID = ist.ProductID
ORDER BY 
    ist.TotalStockAcrossStores DESC;

-- 2. Consulta para identificar productos con distribución desigual entre tiendas
-- Optimizada usando CTE para evitar subconsultas repetidas
WITH ProductAvgStock AS (
    SELECT 
        ProductID, 
        AVG(StockLevel) AS AvgStockLevel
    FROM 
        Inventory
    GROUP BY 
        ProductID
)
SELECT 
    p.ProductName,
    s.StoreName,
    i.StockLevel,
    pas.AvgStockLevel AS AvgStockAcrossStores,
    i.StockLevel - pas.AvgStockLevel AS DeviationFromAverage
FROM 
    Products p
    JOIN Inventory i ON p.ProductID = i.ProductID
    JOIN Stores s ON i.StoreID = s.StoreID
    JOIN ProductAvgStock pas ON p.ProductID = pas.ProductID
ORDER BY 
    p.ProductName, ABS(i.StockLevel - pas.AvgStockLevel) DESC;

-- 3. Consulta para identificar tiendas con niveles de stock críticos
-- Optimizada usando CTEs para mejorar legibilidad y rendimiento
WITH StoreProductCounts AS (
    SELECT 
        s.StoreID,
        s.StoreName,
        COUNT(DISTINCT i.ProductID) AS TotalProducts
    FROM 
        Stores s
        JOIN Inventory i ON s.StoreID = i.StoreID
    GROUP BY 
        s.StoreID, s.StoreName
),
LowStockCounts AS (
    SELECT 
        s.StoreID,
        COUNT(DISTINCT CASE WHEN i.StockLevel < i.MinStockLevel THEN i.ProductID END) AS LowStockProducts
    FROM 
        Stores s
        JOIN Inventory i ON s.StoreID = i.StoreID
    GROUP BY 
        s.StoreID
)
SELECT 
    spc.StoreName,
    lsc.LowStockProducts,
    spc.TotalProducts,
    CAST(lsc.LowStockProducts AS FLOAT) / spc.TotalProducts * 100 AS LowStockPercentage
FROM 
    StoreProductCounts spc
    JOIN LowStockCounts lsc ON spc.StoreID = lsc.StoreID
ORDER BY 
    LowStockPercentage DESC;

-- 4. Consulta para calcular el valor total de inventario por tienda
SELECT 
    s.StoreName,
    SUM(i.StockLevel * p.Price) AS TotalInventoryValue,
    SUM(i.StockLevel * p.Cost) AS TotalInventoryCost,
    SUM(i.StockLevel * (p.Price - p.Cost)) AS PotentialProfit
FROM 
    Stores s
    JOIN Inventory i ON s.StoreID = i.StoreID
    JOIN Products p ON i.ProductID = p.ProductID
GROUP BY 
    s.StoreName
ORDER BY 
    TotalInventoryValue DESC;

-- 5. Consulta para analizar la distribución de categorías por tienda
SELECT 
    s.StoreName,
    c.CategoryName,
    COUNT(DISTINCT i.ProductID) AS NumberOfProducts,
    SUM(i.StockLevel) AS TotalStock,
    SUM(i.StockLevel * p.Price) AS CategoryInventoryValue
FROM 
    Stores s
    JOIN Inventory i ON s.StoreID = i.StoreID
    JOIN Products p ON i.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY 
    s.StoreName, c.CategoryName
ORDER BY 
    s.StoreName, CategoryInventoryValue DESC;

-- 6. Consulta para identificar oportunidades de redistribución de inventario
-- Optimizada usando CTEs para mejorar legibilidad y rendimiento
WITH ExcessInventory AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        s.StoreID,
        s.StoreName,
        i.StockLevel,
        i.MaxStockLevel,
        i.StockLevel - i.MaxStockLevel AS ExcessAmount
    FROM 
        Products p
        JOIN Inventory i ON p.ProductID = i.ProductID
        JOIN Stores s ON i.StoreID = s.StoreID
    WHERE 
        i.StockLevel > i.MaxStockLevel
),
LowInventory AS (
    SELECT 
        p.ProductID,
        s.StoreID,
        s.StoreName,
        i.StockLevel,
        i.MinStockLevel,
        i.MinStockLevel - i.StockLevel AS ShortageAmount
    FROM 
        Products p
        JOIN Inventory i ON p.ProductID = i.ProductID
        JOIN Stores s ON i.StoreID = s.StoreID
    WHERE 
        i.StockLevel < i.MinStockLevel
)
SELECT 
    e.ProductName,
    e.StoreName AS StoreWithExcessStock,
    e.StockLevel AS ExcessStockLevel,
    e.MaxStockLevel AS MaxAllowedStock,
    e.ExcessAmount,
    l.StoreName AS StoreWithLowStock,
    l.StockLevel AS LowStockLevel,
    l.MinStockLevel AS MinRequiredStock,
    l.ShortageAmount
FROM 
    ExcessInventory e
    JOIN LowInventory l ON e.ProductID = l.ProductID
WHERE 
    e.StoreID <> l.StoreID
ORDER BY 
    e.ProductName, e.ExcessAmount DESC;