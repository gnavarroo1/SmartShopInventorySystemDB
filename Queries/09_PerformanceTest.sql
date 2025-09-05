-- SmartShop Inventory System - Script de Prueba de Rendimiento

USE SmartShopInventory;
GO

-- Habilitar estadísticas de tiempo y E/S
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Limpiar caché para pruebas más precisas
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

PRINT '======= PRUEBA DE RENDIMIENTO DE CONSULTAS OPTIMIZADAS =======';
GO

-- Prueba 1: Consulta de consolidación de inventario (06_ConsolidationQueries.sql)
PRINT 'Prueba 1: Consulta de consolidación de inventario';
GO

-- Versión optimizada con CTEs
PRINT 'Versión optimizada:';
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
GO

-- Versión original sin CTEs
PRINT 'Versión original:';
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    SUM(i.StockLevel) AS TotalStockAcrossStores,
    COUNT(DISTINCT i.StoreID) AS NumberOfStoresWithProduct,
    MIN(i.StockLevel) AS MinStockLevel,
    MAX(i.StockLevel) AS MaxStockLevel,
    AVG(i.StockLevel) AS AvgStockLevel
FROM 
    Products p
    JOIN Inventory i ON p.ProductID = i.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY 
    p.ProductID, p.ProductName, c.CategoryName
ORDER BY 
    TotalStockAcrossStores DESC;
GO

-- Prueba 2: Consulta de tiendas con ventas superiores al promedio (07_NestedQueries.sql)
PRINT 'Prueba 2: Consulta de tiendas con ventas superiores al promedio';
GO

-- Versión optimizada con CTEs
PRINT 'Versión optimizada:';
WITH StoreSales AS (
    SELECT 
        s.StoreID,
        s.StoreName,
        s.Location,
        SUM(sales.TotalAmount) AS TotalSales
    FROM 
        Stores s
        JOIN Sales sales ON s.StoreID = sales.StoreID
    GROUP BY 
        s.StoreID, s.StoreName, s.Location
),
AverageSales AS (
    SELECT AVG(TotalSales) AS AvgSales
    FROM StoreSales
)
SELECT 
    ss.StoreID,
    ss.StoreName,
    ss.Location,
    ss.TotalSales AS TotalSalesAmount,
    avg.AvgSales AS AverageSalesAcrossStores
FROM 
    StoreSales ss
    CROSS JOIN AverageSales avg
WHERE 
    ss.TotalSales > avg.AvgSales
ORDER BY 
    ss.TotalSales DESC;
GO

-- Versión original con subconsultas
PRINT 'Versión original:';
SELECT 
    s.StoreID,
    s.StoreName,
    s.Location,
    (
        SELECT SUM(sales.TotalAmount)
        FROM Sales sales
        WHERE sales.StoreID = s.StoreID
    ) AS TotalSalesAmount,
    (
        SELECT AVG(StoreSales.TotalSales)
        FROM (
            SELECT 
                sales_inner.StoreID,
                SUM(sales_inner.TotalAmount) AS TotalSales
            FROM 
                Sales sales_inner
            GROUP BY 
                sales_inner.StoreID
        ) AS StoreSales
    ) AS AverageSalesAcrossStores
FROM 
    Stores s
WHERE 
    (
        SELECT SUM(sales.TotalAmount)
        FROM Sales sales
        WHERE sales.StoreID = s.StoreID
    ) > (
        SELECT AVG(StoreSales.TotalSales)
        FROM (
            SELECT 
                sales_inner.StoreID,
                SUM(sales_inner.TotalAmount) AS TotalSales
            FROM 
                Sales sales_inner
            GROUP BY 
                sales_inner.StoreID
        ) AS StoreSales
    )
ORDER BY 
    TotalSalesAmount DESC;
GO

-- Prueba 3: Consulta de oportunidades de redistribución (06_ConsolidationQueries.sql)
PRINT 'Prueba 3: Consulta de oportunidades de redistribución';
GO

-- Versión optimizada con CTEs
PRINT 'Versión optimizada:';
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
GO

-- Versión original sin CTEs
PRINT 'Versión original:';
SELECT 
    p.ProductName,
    s_excess.StoreName AS StoreWithExcessStock,
    i_excess.StockLevel AS ExcessStockLevel,
    i_excess.MaxStockLevel AS MaxAllowedStock,
    i_excess.StockLevel - i_excess.MaxStockLevel AS ExcessAmount,
    s_low.StoreName AS StoreWithLowStock,
    i_low.StockLevel AS LowStockLevel,
    i_low.MinStockLevel AS MinRequiredStock,
    i_low.MinStockLevel - i_low.StockLevel AS ShortageAmount
FROM 
    Products p
    JOIN Inventory i_excess ON p.ProductID = i_excess.ProductID
    JOIN Stores s_excess ON i_excess.StoreID = s_excess.StoreID
    JOIN Inventory i_low ON p.ProductID = i_low.ProductID
    JOIN Stores s_low ON i_low.StoreID = s_low.StoreID
WHERE 
    i_excess.StockLevel > i_excess.MaxStockLevel
    AND i_low.StockLevel < i_low.MinStockLevel
    AND i_excess.StoreID <> i_low.StoreID
ORDER BY 
    p.ProductName, ExcessAmount DESC;
GO

-- Desactivar estadísticas
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

PRINT '======= FIN DE PRUEBA DE RENDIMIENTO =======';
GO