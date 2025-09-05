-- SmartShop Inventory System - Consultas de Filtrado

USE SmartShopInventory;
GO

-- 1. Filtrar productos por categoría específica
-- Esta consulta muestra todos los productos de la categoría 'Electronics'

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.Description
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    c.CategoryName = 'Electronics';

-- 2. Filtrar productos por múltiples categorías
-- Esta consulta muestra productos que pertenecen a 'Electronics' o 'Home Appliances'

SELECT 
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.Description
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    c.CategoryName IN ('Electronics', 'Home Appliances');

-- 3. Filtrar productos con bajo nivel de stock (por debajo del mínimo recomendado)
-- Esta consulta identifica productos que necesitan reabastecimiento

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

-- 4. Filtrar productos por disponibilidad (en stock)
-- Esta consulta muestra productos que están disponibles (stock > 0)

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
    st.StoreName, p.ProductName;

-- 5. Filtrar productos por categoría y disponibilidad
-- Esta consulta combina filtros para mostrar productos de 'Electronics' que están en stock

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
WHERE 
    c.CategoryName = 'Electronics'
    AND i.StockLevel > 0
ORDER BY 
    st.StoreName, p.ProductName;

-- 6. Filtrar productos por rango de precio
-- Esta consulta muestra productos con precios entre $50 y $200

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

-- 7. Filtrar productos por proveedor
-- Esta consulta muestra todos los productos suministrados por un proveedor específico

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