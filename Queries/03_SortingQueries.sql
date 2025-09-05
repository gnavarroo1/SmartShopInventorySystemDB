-- SmartShop Inventory System - Consultas de Ordenamiento

USE SmartShopInventory;
GO

-- 1. Ordenar productos por precio en orden ascendente (de menor a mayor)
-- Esta consulta muestra todos los productos ordenados del más barato al más caro

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

-- 2. Ordenar productos por precio en orden descendente (de mayor a menor)
-- Esta consulta muestra todos los productos ordenados del más caro al más barato

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

-- 3. Ordenar productos por categoría y luego por precio
-- Esta consulta agrupa productos por categoría y dentro de cada categoría los ordena por precio

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

-- 4. Ordenar productos por nivel de stock (de menor a mayor)
-- Esta consulta muestra productos ordenados por disponibilidad, útil para identificar productos con poco stock

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

-- 5. Ordenar productos por margen de beneficio (de mayor a menor)
-- Esta consulta muestra productos ordenados por rentabilidad

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

-- 6. Combinación de filtrado y ordenamiento: Productos de una categoría específica ordenados por precio
-- Esta consulta filtra productos de 'Electronics' y los ordena por precio ascendente

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

-- 7. Combinación de filtrado y ordenamiento: Productos con bajo stock ordenados por nivel de stock
-- Esta consulta muestra productos con stock bajo del mínimo recomendado, ordenados por nivel de stock

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