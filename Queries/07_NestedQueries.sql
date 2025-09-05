-- SmartShop Inventory System - Nested Queries for Advanced Analysis

USE SmartShopInventory;
GO

-- 1. Consulta para calcular el total de ventas por producto
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    (
        SELECT SUM(sd.Quantity)
        FROM SaleDetails sd
        WHERE sd.ProductID = p.ProductID
    ) AS TotalUnitsSold,
    (
        SELECT SUM(sd.Quantity * sd.UnitPrice)
        FROM SaleDetails sd
        WHERE sd.ProductID = p.ProductID
    ) AS TotalSalesAmount
FROM 
    Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE 
    EXISTS (
        SELECT 1 FROM SaleDetails sd WHERE sd.ProductID = p.ProductID
    )
ORDER BY 
    TotalSalesAmount DESC;

-- 2. Consulta para identificar proveedores con entregas más demoradas
-- Nota: Esta consulta es simulada ya que no tenemos datos reales de entregas
-- En un sistema real, tendríamos una tabla de entregas con fechas
SELECT 
    s.SupplierID,
    s.SupplierName,
    (
        SELECT COUNT(DISTINCT p.ProductID)
        FROM Products p
        JOIN Inventory i ON p.ProductID = i.ProductID
        WHERE p.SupplierID = s.SupplierID AND i.StockLevel < i.MinStockLevel
    ) AS LowStockProducts,
    (
        SELECT COUNT(DISTINCT p.ProductID)
        FROM Products p
        WHERE p.SupplierID = s.SupplierID
    ) AS TotalProducts
FROM 
    Suppliers s
WHERE 
    (
        SELECT COUNT(DISTINCT p.ProductID)
        FROM Products p
        JOIN Inventory i ON p.ProductID = i.ProductID
        WHERE p.SupplierID = s.SupplierID AND i.StockLevel < i.MinStockLevel
    ) > 0
ORDER BY 
    LowStockProducts DESC;

-- 3. Consulta para analizar productos que nunca se han vendido
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.SupplierName,
    (
        SELECT SUM(i.StockLevel)
        FROM Inventory i
        WHERE i.ProductID = p.ProductID
    ) AS TotalStock,
    p.Price
FROM 
    Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE 
    NOT EXISTS (
        SELECT 1 FROM SaleDetails sd WHERE sd.ProductID = p.ProductID
    )
ORDER BY 
    p.Price DESC;

-- 4. Consulta para encontrar productos con ventas superiores al promedio de su categoría
-- Optimizada usando CTEs para mejorar legibilidad y rendimiento
WITH ProductSales AS (
    SELECT 
        p.ProductID,
        p.CategoryID,
        SUM(sd.Quantity) AS TotalSold
    FROM 
        Products p
        JOIN SaleDetails sd ON p.ProductID = sd.ProductID
    GROUP BY 
        p.ProductID, p.CategoryID
),
CategoryAverages AS (
    SELECT 
        ps.CategoryID,
        AVG(ps.TotalSold) AS AvgCategorySales
    FROM 
        ProductSales ps
    GROUP BY 
        ps.CategoryID
)
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    ps.TotalSold AS TotalUnitsSold,
    ca.AvgCategorySales AS CategoryAverageSales
FROM 
    Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    JOIN ProductSales ps ON p.ProductID = ps.ProductID
    JOIN CategoryAverages ca ON p.CategoryID = ca.CategoryID
WHERE 
    ps.TotalSold > ca.AvgCategorySales
ORDER BY 
    c.CategoryName, ps.TotalSold DESC;

-- 5. Consulta para analizar tiendas con ventas superiores al promedio
-- Optimizada usando CTEs para mejorar legibilidad y rendimiento
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

-- 6. Consulta para analizar el rendimiento de ventas por día de la semana
-- Optimizada usando CTEs para mejorar legibilidad y rendimiento
WITH DailySales AS (
    SELECT 
        CONVERT(DATE, sales_inner.SaleDate) AS SaleDay,
        SUM(sales_inner.TotalAmount) AS DailyTotal
    FROM 
        Sales sales_inner
    GROUP BY 
        CONVERT(DATE, sales_inner.SaleDate)
),
AverageDailySales AS (
    SELECT AVG(DailyTotal) AS AvgDailySales
    FROM DailySales
),
WeekdaySales AS (
    SELECT 
        DATENAME(WEEKDAY, s.SaleDate) AS DayOfWeek,
        COUNT(DISTINCT s.SaleID) AS NumberOfSales,
        SUM(s.TotalAmount) AS TotalSalesAmount,
        AVG(s.TotalAmount) AS AverageSaleAmount,
        (
            SELECT TOP 1 p.ProductName
            FROM SaleDetails sd
            JOIN Products p ON sd.ProductID = p.ProductID
            JOIN Sales s_inner ON sd.SaleID = s_inner.SaleID
            WHERE DATENAME(WEEKDAY, s_inner.SaleDate) = DATENAME(WEEKDAY, s.SaleDate)
            GROUP BY p.ProductName
            ORDER BY SUM(sd.Quantity) DESC
        ) AS TopSellingProduct
    FROM 
        Sales s
    GROUP BY 
        DATENAME(WEEKDAY, s.SaleDate)
)
SELECT 
    ws.DayOfWeek,
    ws.NumberOfSales,
    ws.TotalSalesAmount,
    ws.AverageSaleAmount,
    ws.TopSellingProduct,
    ads.AvgDailySales AS AverageDailySales,
    CASE 
        WHEN ws.TotalSalesAmount > ads.AvgDailySales THEN 'Above Average'
        ELSE 'Below Average'
    END AS PerformanceCategory
FROM 
    WeekdaySales ws
    CROSS JOIN AverageDailySales ads
ORDER BY 
    CASE ws.DayOfWeek
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
    END;