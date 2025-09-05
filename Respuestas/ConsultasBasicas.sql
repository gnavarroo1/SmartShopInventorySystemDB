-- SmartShop Inventory System - Basic Queries
-- This file contains all the basic queries of the system

-- =============================================
-- PRODUCT QUERIES
-- =============================================

-- 1. Query to retrieve product details
-- This query shows all product information with their category and supplier

SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.SupplierName,
    p.Description,
    p.Price,
    p.Cost
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
ORDER BY 
    p.ProductName;

-- 2. Query to get inventory summary by product
-- This query shows stock levels for each product across all stores

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel,
    i.MinStockLevel,
    i.MaxStockLevel
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
ORDER BY 
    p.ProductName, st.StoreName;

-- 3. Query to calculate total inventory value by product
-- This query shows the total value of inventory for each product

SELECT 
    p.ProductName,
    c.CategoryName,
    SUM(i.StockLevel) AS TotalStock,
    p.Price AS UnitPrice,
    SUM(i.StockLevel * p.Price) AS TotalInventoryValue
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    p.ProductName, c.CategoryName, p.Price
ORDER BY 
    TotalInventoryValue DESC;

-- 4. Query to calculate profit margin by product
-- This query shows the profit margin for each product

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Cost AS CostPrice,
    p.Price AS SellingPrice,
    (p.Price - p.Cost) AS ProfitPerUnit,
    ((p.Price - p.Cost) / p.Cost * 100) AS ProfitMarginPercentage
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    ProfitMarginPercentage DESC;

-- =============================================
-- FILTERING QUERIES
-- =============================================

-- 1. Filter products by category
-- This query shows all products in the 'Electronics' category

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Description,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    c.CategoryName = 'Electronics'
ORDER BY 
    p.ProductName;

-- 2. Filter products by multiple categories
-- This query shows products in either 'Electronics' or 'Home Appliances' categories

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Description,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    c.CategoryName IN ('Electronics', 'Home Appliances')
ORDER BY 
    c.CategoryName, p.ProductName;

-- 3. Filter products by low stock level
-- This query shows products with stock below the minimum recommended level

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel,
    i.MinStockLevel,
    (i.MinStockLevel - i.StockLevel) AS UnitsNeeded
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
WHERE 
    i.StockLevel < i.MinStockLevel
ORDER BY 
    UnitsNeeded DESC;

-- 4. Filter products by availability
-- This query shows products that are currently in stock

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
WHERE 
    i.StockLevel > 0
ORDER BY 
    p.ProductName;

-- 5. Combination of category and availability filters
-- This query shows products in the 'Electronics' category that are in stock

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
WHERE 
    c.CategoryName = 'Electronics'
    AND i.StockLevel > 0
ORDER BY 
    st.StoreName, p.ProductName;

-- 6. Filter products by price range
-- This query shows products with prices between $50 and $200

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    p.Price BETWEEN 50 AND 200
ORDER BY 
    p.Price;

-- 7. Filter products by supplier
-- This query shows all products supplied by a specific supplier

SELECT 
    p.ProductName,
    c.CategoryName,
    s.SupplierName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
WHERE 
    s.SupplierName = 'TechSupply Inc.'
ORDER BY 
    p.ProductName;

-- =============================================
-- SORTING QUERIES
-- =============================================

-- 1. Sort products by price in ascending order (from lowest to highest)
-- This query shows all products ordered from cheapest to most expensive

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    p.Price ASC;

-- 2. Sort products by price in descending order (from highest to lowest)
-- This query shows all products ordered from most expensive to cheapest

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    p.Price DESC;

-- 3. Sort products by category and then by price
-- This query groups products by category and within each category orders them by price

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    c.CategoryName, p.Price ASC;

-- 4. Sort products by stock level (from lowest to highest)
-- This query shows products ordered by availability, useful for identifying products with low stock

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
ORDER BY 
    i.StockLevel ASC;

-- 5. Sort products by profit margin (from highest to lowest)
-- This query shows products ordered by profitability

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Cost AS CostPrice,
    p.Price AS SellingPrice,
    (p.Price - p.Cost) AS ProfitPerUnit,
    ((p.Price - p.Cost) / p.Cost * 100) AS ProfitMarginPercentage
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    ProfitMarginPercentage DESC;

-- 6. Combination of filtering and sorting: Products from a specific category ordered by price
-- This query filters products from 'Electronics' and orders them by ascending price

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    c.CategoryName = 'Electronics'
ORDER BY 
    p.Price ASC;

-- 7. Combination of filtering and sorting: Products with low stock ordered by stock level
-- This query shows products with stock below the minimum recommended level, ordered by stock level

SELECT 
    p.ProductName,
    c.CategoryName,
    st.StoreName,
    i.StockLevel,
    i.MinStockLevel,
    (i.MinStockLevel - i.StockLevel) AS UnitsNeeded
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
WHERE 
    i.StockLevel < i.MinStockLevel
ORDER BY 
    i.StockLevel ASC;