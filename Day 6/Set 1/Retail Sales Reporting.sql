CREATE DATABASE RetailSalesDB;
GO
USE RetailSalesDB;
GO

CREATE TABLE dbo.customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(80) NOT NULL,
    City         NVARCHAR(60) NOT NULL,
    Phone        VARCHAR(15) NULL
);

CREATE TABLE dbo.products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Category    NVARCHAR(60) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.orders (
    OrderID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.customers(CustomerID),
    OrderDate  DATE NOT NULL,
    Discount   DECIMAL(5,2) NULL
);

CREATE TABLE dbo.order_items (
    ItemID    INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT NOT NULL REFERENCES dbo.orders(OrderID),
    ProductID INT NOT NULL REFERENCES dbo.products(ProductID),
    Quantity  INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT NOT NULL REFERENCES dbo.orders(OrderID),
    Amount    DECIMAL(10,2) NOT NULL
);
GO

INSERT INTO dbo.customers (CustomerName, City, Phone) VALUES
(N'Arun', N'Chennai', '9000000001'),
(N'Divya', N'Chennai', NULL),
(N'Karthik', N'Coimbatore', '9000000003'),
(N'Meena', N'Bengaluru', '9000000004'),
(N'Rahul', N'Bengaluru', NULL),
(N'Sneha', N'Mumbai', '9000000006'),
(N'Vikram', N'Chennai', '9000000007'),
(N'Priya', N'Coimbatore', NULL);

INSERT INTO dbo.products (ProductName, Category, Price) VALUES
(N'Wireless Mouse', N'Electronics', 500),
(N'USB-C Hub', N'Electronics', 1200),
(N'Electric Kettle', N'Home Appliances', 1500),
(N'Yoga Mat', N'Sports', 800),
(N'Notebook Pack', N'Stationery', 200),
(N'Office Chair', N'Furniture', 4000);

INSERT INTO dbo.orders (CustomerID, OrderDate, Discount) VALUES
(1, '2026-01-05', 10), (1, '2026-01-20', NULL), (1, '2026-02-10', 5), (1, '2026-02-25', NULL),
(2, '2026-01-20', 10), (2, '2026-02-14', NULL),
(3, '2026-02-25', NULL), (3, '2026-03-03', 5),
(4, '2026-03-03', NULL), (4, '2026-03-15', 15),
(5, '2026-03-18', NULL), (6, '2026-03-03', NULL);

INSERT INTO dbo.order_items (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 2, 500), (1, 5, 5, 200), (2, 2, 1, 1200), (3, 6, 1, 4000),
(4, 4, 2, 800), (5, 3, 1, 1500), (6, 1, 3, 500), (7, 6, 2, 4000),
(8, 2, 2, 1200), (8, 5, 10, 200), (9, 3, 2, 1500), (10, 4, 1, 800),
(11, 1, 4, 500), (12, 6, 1, 4000), (12, 2, 1, 1200);

INSERT INTO dbo.payments (OrderID, Amount) VALUES
(1, 2000), (2, 1200), (3, 4000), (4, 1600), (5, 1500),
(6, 1500), (7, 8000), (8, 4400), (9, 3000), (10, 800);
GO

CREATE VIEW dbo.OrderTotals AS
SELECT o.OrderID, o.CustomerID, o.OrderDate, SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM dbo.orders AS o
JOIN dbo.order_items AS oi ON oi.OrderID = o.OrderID
GROUP BY o.OrderID, o.CustomerID, o.OrderDate;
GO

SELECT TOP 5 p.ProductName, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM dbo.order_items AS oi
JOIN dbo.products AS p ON p.ProductID = oi.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC, p.ProductName;

SELECT FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth, COUNT(*) AS Orders, SUM(OrderTotal) AS Sales
FROM dbo.OrderTotals
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY SalesMonth;

SELECT c.CustomerName, COUNT(*) AS OrderCount
FROM dbo.customers AS c
JOIN dbo.orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName
HAVING COUNT(*) > 3;

SELECT c.City, CAST(AVG(ot.OrderTotal) AS DECIMAL(10,2)) AS AvgBasketValue
FROM dbo.OrderTotals AS ot
JOIN dbo.customers AS c ON c.CustomerID = ot.CustomerID
GROUP BY c.City
ORDER BY AvgBasketValue DESC;

SELECT o.OrderID, c.CustomerName, o.OrderDate
FROM dbo.orders AS o
JOIN dbo.customers AS c ON c.CustomerID = o.CustomerID
LEFT JOIN dbo.payments AS pay ON pay.OrderID = o.OrderID
WHERE pay.PaymentID IS NULL;

SELECT c.CustomerID, c.CustomerName, c.City
FROM dbo.customers AS c
LEFT JOIN dbo.orders AS o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;

SELECT p.Category,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
       CAST(100.0 * SUM(oi.Quantity * oi.UnitPrice) / SUM(SUM(oi.Quantity * oi.UnitPrice)) OVER () AS DECIMAL(5,2)) AS SharePct
FROM dbo.order_items AS oi
JOIN dbo.products AS p ON p.ProductID = oi.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC;

SELECT TOP 1 OrderDate, SUM(OrderTotal) AS DaySales
FROM dbo.OrderTotals
GROUP BY OrderDate
ORDER BY DaySales DESC;

SELECT CONCAT(UPPER(c.CustomerName), ' from ', c.City,
       ': first order on ', FORMAT(MIN(ot.OrderDate), 'dd MMM yyyy'),
       ', active for ', DATEDIFF(DAY, MIN(ot.OrderDate), MAX(ot.OrderDate)),
       ' days, avg basket Rs ', CAST(ROUND(AVG(ot.OrderTotal), 2) AS DECIMAL(10,2))) AS CustomerSummary
FROM dbo.OrderTotals AS ot
JOIN dbo.customers AS c ON c.CustomerID = ot.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.City
ORDER BY c.CustomerID;

SELECT COUNT(*) AS CountStar,
       COUNT(Discount) AS CountDiscount,
       CAST(AVG(Discount) AS DECIMAL(5,2)) AS AvgIgnoringNull,
       CAST(AVG(COALESCE(Discount, 0)) AS DECIMAL(5,2)) AS AvgNullAsZero
FROM dbo.orders;
