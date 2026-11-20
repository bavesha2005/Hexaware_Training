/*
DAY 9 — RETAIL ORDER FULFILMENT
CONSOLIDATED SQL SERVER SCRIPT

Run this single file in SQL Server Management Studio (SSMS).
Sections are ordered: schema/setup → views → procedures/functions → cursor/set-based.
*/


/* ============================================================
   SCHEMA SETUP
   ============================================================ */

IF DB_ID(N'RetailFulfilmentDB') IS NULL CREATE DATABASE RetailFulfilmentDB;
GO
USE RetailFulfilmentDB;
GO
DROP TABLE IF EXISTS dbo.OrderFollowUps;
DROP TABLE IF EXISTS dbo.OrderLines;
DROP TABLE IF EXISTS dbo.RetailOrders;
DROP TABLE IF EXISTS dbo.RetailProducts;
DROP TABLE IF EXISTS dbo.Suppliers;
DROP TABLE IF EXISTS dbo.RetailCustomers;
GO
CREATE TABLE dbo.RetailCustomers(CustomerID INT IDENTITY PRIMARY KEY,CustomerName NVARCHAR(100) NOT NULL,Email NVARCHAR(150) NOT NULL UNIQUE);
CREATE TABLE dbo.Suppliers(SupplierID INT IDENTITY PRIMARY KEY,SupplierName NVARCHAR(100) NOT NULL,ContactEmail NVARCHAR(150));
CREATE TABLE dbo.RetailProducts(ProductID INT IDENTITY PRIMARY KEY,ProductName NVARCHAR(100) NOT NULL,SupplierID INT NOT NULL REFERENCES dbo.Suppliers(SupplierID),CostPrice DECIMAL(12,2) NOT NULL CHECK(CostPrice>=0),UnitPrice DECIMAL(12,2) NOT NULL CHECK(UnitPrice>=0),StockQuantity INT NOT NULL CHECK(StockQuantity>=0),ReorderLevel INT NOT NULL DEFAULT 5,IsActive BIT NOT NULL DEFAULT 1);
CREATE TABLE dbo.RetailOrders(OrderID INT IDENTITY(1001,1) PRIMARY KEY,CustomerID INT NOT NULL REFERENCES dbo.RetailCustomers(CustomerID),OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),OrderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(OrderStatus IN('Pending','Processing','Shipped','Delivered','Cancelled')));
CREATE TABLE dbo.OrderLines(OrderLineID INT IDENTITY PRIMARY KEY,OrderID INT NOT NULL REFERENCES dbo.RetailOrders(OrderID),ProductID INT NOT NULL REFERENCES dbo.RetailProducts(ProductID),Quantity INT NOT NULL CHECK(Quantity>0),UnitPrice DECIMAL(12,2) NOT NULL);
CREATE TABLE dbo.OrderFollowUps(FollowUpID INT IDENTITY PRIMARY KEY,OrderID INT NOT NULL UNIQUE REFERENCES dbo.RetailOrders(OrderID),CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),FollowUpNote NVARCHAR(250) NOT NULL);
INSERT dbo.RetailCustomers(CustomerName,Email) VALUES(N'Asha Kumar',N'asha@example.com'),(N'Ravi Shah',N'ravi@example.com'),(N'Meera Das',N'meera@example.com');
INSERT dbo.Suppliers(SupplierName,ContactEmail) VALUES(N'Northstar Supplies',N'sales@northstar.example'),(N'City Wholesale',N'orders@citywholesale.example');
INSERT dbo.RetailProducts(ProductName,SupplierID,CostPrice,UnitPrice,StockQuantity,ReorderLevel) VALUES(N'Wireless Mouse',1,420,750,20,5),(N'Mechanical Keyboard',1,1450,2500,8,4),(N'USB-C Hub',2,900,1600,3,5),(N'Notebook',2,35,100,50,10);
INSERT dbo.RetailOrders(CustomerID,OrderDate,OrderStatus) VALUES(1,DATEADD(DAY,-5,SYSDATETIME()),'Pending'),(2,DATEADD(DAY,-1,SYSDATETIME()),'Pending'),(3,DATEADD(DAY,-8,SYSDATETIME()),'Shipped');
INSERT dbo.OrderLines(OrderID,ProductID,Quantity,UnitPrice) VALUES(1001,1,2,750),(1001,4,3,100),(1002,2,1,2500),(1003,3,1,1600);
GO



/* ============================================================
   VIEWS
   ============================================================ */

USE RetailFulfilmentDB;
GO
CREATE OR ALTER VIEW dbo.vw_order_summary AS
SELECT o.OrderID,o.OrderDate,o.OrderStatus,c.CustomerID,c.CustomerName,
       COUNT(ol.OrderLineID) AS LineCount,COALESCE(SUM(ol.Quantity*ol.UnitPrice),0) AS OrderSubtotal
FROM dbo.RetailOrders o JOIN dbo.RetailCustomers c ON c.CustomerID=o.CustomerID
LEFT JOIN dbo.OrderLines ol ON ol.OrderID=o.OrderID
GROUP BY o.OrderID,o.OrderDate,o.OrderStatus,c.CustomerID,c.CustomerName;
GO
CREATE OR ALTER VIEW dbo.vw_low_stock AS
SELECT ProductID,ProductName,StockQuantity,ReorderLevel
FROM dbo.RetailProducts WHERE StockQuantity<=ReorderLevel;
GO
CREATE OR ALTER VIEW dbo.vw_active_products AS
SELECT ProductID,ProductName,UnitPrice,StockQuantity,ReorderLevel,IsActive
FROM dbo.RetailProducts WHERE IsActive=1 WITH CHECK OPTION;
GO
SELECT * FROM dbo.vw_order_summary;
SELECT * FROM dbo.vw_low_stock;
UPDATE dbo.vw_active_products SET UnitPrice=UnitPrice WHERE ProductID=1;
-- Rejected by WITH CHECK OPTION because the updated row would no longer satisfy IsActive=1:
-- UPDATE dbo.vw_active_products SET IsActive=0 WHERE ProductID=1;
GO



/* ============================================================
   STORED PROCEDURES AND FUNCTIONS
   ============================================================ */

USE RetailFulfilmentDB;
GO
IF TYPE_ID(N'dbo.OrderLineInput') IS NULL
 EXEC(N'CREATE TYPE dbo.OrderLineInput AS TABLE(ProductID INT NOT NULL,Quantity INT NOT NULL CHECK(Quantity>0))');
GO
CREATE OR ALTER FUNCTION dbo.fn_OrderTotalWithTax(@OrderID INT,@TaxRate DECIMAL(6,4))
RETURNS DECIMAL(14,2)
AS
BEGIN
 DECLARE @Total DECIMAL(14,2);
 SELECT @Total=COALESCE(SUM(Quantity*UnitPrice),0)*(1+@TaxRate)
 FROM dbo.OrderLines WHERE OrderID=@OrderID;
 RETURN @Total;
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_CustomerOrders(@CustomerID INT)
RETURNS TABLE AS RETURN
(
 SELECT o.OrderID,o.OrderDate,o.OrderStatus,COALESCE(SUM(ol.Quantity*ol.UnitPrice),0) AS OrderSubtotal
 FROM dbo.RetailOrders o LEFT JOIN dbo.OrderLines ol ON ol.OrderID=o.OrderID
 WHERE o.CustomerID=@CustomerID GROUP BY o.OrderID,o.OrderDate,o.OrderStatus
);
GO
CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
 @CustomerID INT,@Lines dbo.OrderLineInput READONLY,@OrderNumber INT OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  IF NOT EXISTS(SELECT 1 FROM dbo.RetailCustomers WHERE CustomerID=@CustomerID) THROW 51001,'Customer does not exist.',1;
  IF NOT EXISTS(SELECT 1 FROM @Lines) THROW 51002,'At least one order line is required.',1;
  IF EXISTS(SELECT 1 FROM @Lines l LEFT JOIN dbo.RetailProducts p ON p.ProductID=l.ProductID WHERE p.ProductID IS NULL OR p.IsActive=0) THROW 51003,'A product is missing or inactive.',1;
  BEGIN TRANSACTION;
  IF EXISTS(
    SELECT 1 FROM (SELECT ProductID,SUM(Quantity) Qty FROM @Lines GROUP BY ProductID) x
    JOIN dbo.RetailProducts p WITH(UPDLOCK,HOLDLOCK) ON p.ProductID=x.ProductID
    WHERE p.StockQuantity<x.Qty OR p.IsActive=0
  ) THROW 51004,'Insufficient stock or product inactive.',1;
  INSERT dbo.RetailOrders(CustomerID,OrderStatus) VALUES(@CustomerID,'Pending');
  SET @OrderNumber=CONVERT(INT,SCOPE_IDENTITY());
  INSERT dbo.OrderLines(OrderID,ProductID,Quantity,UnitPrice)
   SELECT @OrderNumber,l.ProductID,l.Quantity,p.UnitPrice FROM @Lines l JOIN dbo.RetailProducts p ON p.ProductID=l.ProductID;
  UPDATE p SET StockQuantity=p.StockQuantity-x.Qty
   FROM dbo.RetailProducts p JOIN(SELECT ProductID,SUM(Quantity) Qty FROM @Lines GROUP BY ProductID)x ON x.ProductID=p.ProductID;
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @OrderNumber=NULL; THROW;
 END CATCH
END;
GO
-- Example:
-- DECLARE @L dbo.OrderLineInput,@N INT;
-- INSERT @L VALUES(1,2),(4,1);
-- EXEC dbo.usp_PlaceOrder 1,@L,@N OUTPUT;
-- SELECT @N AS NewOrderNumber,dbo.fn_OrderTotalWithTax(@N,0.18) AS TotalWithTax;
-- SELECT * FROM dbo.fn_CustomerOrders(1);
GO



/* ============================================================
   CURSOR AND SET-BASED ALTERNATIVE
   ============================================================ */

USE RetailFulfilmentDB;
GO
-- Cursor approach: one follow-up row per pending order older than 3 days.
DECLARE @OrderID INT;
DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR
 SELECT OrderID FROM dbo.RetailOrders
 WHERE OrderStatus='Pending' AND OrderDate<DATEADD(DAY,-3,SYSDATETIME())
 AND NOT EXISTS(SELECT 1 FROM dbo.OrderFollowUps f WHERE f.OrderID=RetailOrders.OrderID);
OPEN order_cursor;
FETCH NEXT FROM order_cursor INTO @OrderID;
WHILE @@FETCH_STATUS=0
BEGIN
 INSERT dbo.OrderFollowUps(OrderID,FollowUpNote)
 VALUES(@OrderID,N'Please contact the customer: order has been pending for more than three days.');
 FETCH NEXT FROM order_cursor INTO @OrderID;
END;
CLOSE order_cursor; DEALLOCATE order_cursor;
GO
-- Set-based equivalent; NOT EXISTS makes it safe to rerun.
INSERT dbo.OrderFollowUps(OrderID,FollowUpNote)
SELECT o.OrderID,N'Please contact the customer: order has been pending for more than three days.'
FROM dbo.RetailOrders o
WHERE o.OrderStatus='Pending' AND o.OrderDate<DATEADD(DAY,-3,SYSDATETIME())
AND NOT EXISTS(SELECT 1 FROM dbo.OrderFollowUps f WHERE f.OrderID=o.OrderID);
GO
SELECT * FROM dbo.OrderFollowUps;

