-- SmartShop Inventory System - Consultas Básicas de Productos

USE SmartShopInventory;
GO

-- 1. Consulta básica para recuperar detalles de productos
-- Esta consulta obtiene información básica de todos los productos: nombre, categoría, precio y nivel de stock

SELECT 
    p.ProductName, 
    c.CategoryName, 
    p.Price, 
    i.StockLevel
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
WHERE 
    i.StoreID = 1; -- Filtro para mostrar solo productos de la tienda Central

-- 2. Consulta para obtener detalles completos de un producto específico

SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.SupplierName,
    p.Description,
    p.Price,
    p.Cost,
    p.SKU,
    i.StockLevel,
    i.MinStockLevel,
    i.MaxStockLevel,
    st.StoreName,
    i.LastUpdated
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
INNER JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
INNER JOIN 
    Stores st ON i.StoreID = st.StoreID
WHERE 
    p.ProductID = 1; -- Cambiar el ID según el producto que se desee consultar

-- 3. Consulta para obtener un resumen del inventario por producto en todas las tiendas

SELECT 
    p.ProductName,
    SUM(i.StockLevel) AS TotalStock,
    COUNT(i.StoreID) AS StoreCount,
    MIN(i.StockLevel) AS MinStockAvailable,
    MAX(i.StockLevel) AS MaxStockAvailable,
    AVG(i.StockLevel) AS AvgStockPerStore
FROM 
    Products p
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    p.ProductName;

-- 4. Consulta para obtener el valor total del inventario por producto

SELECT 
    p.ProductName,
    p.Price,
    SUM(i.StockLevel) AS TotalStock,
    SUM(i.StockLevel * p.Price) AS TotalInventoryValue
FROM 
    Products p
INNER JOIN 
    Inventory i ON p.ProductID = i.ProductID
GROUP BY 
    p.ProductName, p.Price
ORDER BY 
    TotalInventoryValue DESC;

-- 5. Consulta para obtener el margen de beneficio por producto

SELECT 
    p.ProductName,
    p.Cost AS CostPrice,
    p.Price AS SellingPrice,
    (p.Price - p.Cost) AS ProfitPerUnit,
    ((p.Price - p.Cost) / p.Cost * 100) AS ProfitMarginPercentage
FROM 
    Products p
ORDER BY 
    ProfitMarginPercentage DESC;