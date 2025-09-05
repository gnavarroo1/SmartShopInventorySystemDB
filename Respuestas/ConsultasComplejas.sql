-- SmartShop Inventory System - Complex Queries
-- This file contains all the complex queries of the system

-- =============================================
-- JOIN QUERIES FOR SALES TREND ANALYSIS
-- =============================================

-- 1. Query to show sales details with product and store information
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

-- 2. Query to analyze sales by product category
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

-- 3. Query to analyze sales by store
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

-- 4. Query to analyze sales by date
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

-- 5. Query to analyze best-selling products by store
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

-- 6. Query to analyze sales by supplier
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

-- 7. Query to analyze profit margin by sale
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

-- =============================================
-- AGGREGATION FUNCTION QUERIES FOR SUPPLIER REPORTS
-- =============================================

-- 1. Query to identify best-performing suppliers based on delivered stock
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

-- 2. Query to calculate total inventory value by supplier
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

-- 3. Query to analyze category diversity by supplier
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

-- 4. Query to identify suppliers with low-stock products
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

-- 5. Query to calculate average, minimum, and maximum product prices by supplier
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

-- 6. Query to analyze average profit margin by supplier
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

-- =============================================
-- QUERIES TO CONSOLIDATE INVENTORY DATA ACROSS STORES
-- =============================================

-- 1. Query to consolidate inventory levels by product across all stores
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

-- 2. Query to identify products with uneven distribution across stores
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

-- 3. Query to identify stores with critical stock levels
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

-- 4. Query to calculate total inventory value by store
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

-- 5. Query to analyze category distribution by store
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

-- 6. Query to identify inventory redistribution opportunities
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

-- =============================================
-- NESTED QUERIES FOR ADVANCED ANALYSIS
-- =============================================

-- 1. Query to calculate total sales by product
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

-- 2. Query to identify suppliers with delayed deliveries
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

-- 3. Query to analyze products that have never been sold
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

-- 4. Query to find products with above-average sales for their category
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

-- 5. Query to analyze stores with above-average sales
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

-- 6. Query to analyze sales performance by day of the week
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