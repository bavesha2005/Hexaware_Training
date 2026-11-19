CREATE DATABASE RetailInventoryDB;

USE RetailInventoryDB;

CREATE TABLE dbo.RetailProducts
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(60) NOT NULL,
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0)
);

CREATE TABLE dbo.RetailOrders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    OrderStatus VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.OrderLines
(
    OrderLineID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderLines_Orders FOREIGN KEY (OrderID)
        REFERENCES dbo.RetailOrders(OrderID),
    CONSTRAINT FK_OrderLines_Products FOREIGN KEY (ProductID)
        REFERENCES dbo.RetailProducts(ProductID)
);

INSERT INTO dbo.RetailProducts
    (ProductID, ProductName, Category, StockQuantity, UnitPrice)
VALUES
(1, 'Wireless Mouse', 'Electronics', 20, 750.00),
(2, 'Mechanical Keyboard', 'Electronics', 8, 2500.00),
(3, 'USB-C Hub', 'Electronics', 4, 1800.00),
(4, 'Notebook', 'Stationery', 50, 100.00),
(5, 'Pen Set', 'Stationery', 15, 250.00);
GO

/* 1. Reserve stock, create order and order lines atomically. */
DECLARE @CustomerName VARCHAR(100) = 'Kiran';
DECLARE @OrderID INT;
DECLARE @ProductID INT = 1;
DECLARE @Quantity INT = 3;
DECLARE @UnitPrice DECIMAL(10,2);

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @UnitPrice = UnitPrice
    FROM dbo.RetailProducts WITH (UPDLOCK, HOLDLOCK)
    WHERE ProductID = @ProductID
      AND StockQuantity >= @Quantity;

    IF @UnitPrice IS NULL
        THROW 50201, 'Product not found or insufficient stock.', 1;

    UPDATE dbo.RetailProducts
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID
      AND StockQuantity >= @Quantity;

    IF @@ROWCOUNT <> 1
        THROW 50202, 'Stock reservation failed.', 1;

    INSERT INTO dbo.RetailOrders (CustomerName, OrderStatus)
    VALUES (@CustomerName, 'PLACED');

    SET @OrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderLines (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);

    COMMIT TRANSACTION;
    PRINT 'Order and stock reservation committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT CONCAT('Order failed: ', ERROR_MESSAGE());
    THROW;
END CATCH;
GO

/* Rollback proof: insufficient stock must not create an order or change stock. */
DECLARE @StockBefore INT;
DECLARE @OrdersBefore INT;
DECLARE @OrderLinesBefore INT;
DECLARE @FailedOrderID INT;
DECLARE @RequestedProductID INT = 3;
DECLARE @RequestedQuantity INT = 999;
DECLARE @Price DECIMAL(10,2);

SELECT @StockBefore = StockQuantity
FROM dbo.RetailProducts WHERE ProductID = @RequestedProductID;
SELECT @OrdersBefore = COUNT(*) FROM dbo.RetailOrders;
SELECT @OrderLinesBefore = COUNT(*) FROM dbo.OrderLines;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @Price = UnitPrice
    FROM dbo.RetailProducts WITH (UPDLOCK, HOLDLOCK)
    WHERE ProductID = @RequestedProductID
      AND StockQuantity >= @RequestedQuantity;

    IF @Price IS NULL
        THROW 50210, 'Insufficient stock for requested quantity.', 1;

    UPDATE dbo.RetailProducts
    SET StockQuantity = StockQuantity - @RequestedQuantity
    WHERE ProductID = @RequestedProductID;

    INSERT INTO dbo.RetailOrders (CustomerName, OrderStatus)
    VALUES ('Test Customer', 'PLACED');

    SET @FailedOrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderLines (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@FailedOrderID, @RequestedProductID, @RequestedQuantity, @Price);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT CONCAT('Expected reservation failure: ', ERROR_MESSAGE());
END CATCH;

SELECT
    @StockBefore AS StockBefore,
    (SELECT StockQuantity FROM dbo.RetailProducts
     WHERE ProductID = @RequestedProductID) AS StockAfter,
    @OrdersBefore AS OrdersBefore,
    (SELECT COUNT(*) FROM dbo.RetailOrders) AS OrdersAfter,
    @OrderLinesBefore AS OrderLinesBefore,
    (SELECT COUNT(*) FROM dbo.OrderLines) AS OrderLinesAfter;
GO

/* 2. Products whose stock is below their category's average stock. */
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQuantity
FROM dbo.RetailProducts AS p
WHERE p.StockQuantity <
(
    SELECT AVG(CAST(p2.StockQuantity AS DECIMAL(10,2)))
    FROM dbo.RetailProducts AS p2
    WHERE p2.Category = p.Category
)
ORDER BY p.Category, p.StockQuantity;
GO



/* SECTION 2: rank_report.sql */
/*
Sample sales data for the reporting tasks.
The report ranks products by units sold within each category and returns
the top three. A second report uses LAG and LEAD for month-to-month change.
*/

DROP TABLE IF EXISTS dbo.ProductSales;
GO

CREATE TABLE dbo.ProductSales
(
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(60) NOT NULL,
    SaleMonth DATE NOT NULL,
    UnitsSold INT NOT NULL CHECK (UnitsSold >= 0)
);

INSERT INTO dbo.ProductSales (ProductID, ProductName, Category, SaleMonth, UnitsSold)
VALUES
(1, 'Wireless Mouse', 'Electronics', '2026-01-01', 40),
(1, 'Wireless Mouse', 'Electronics', '2026-02-01', 55),
(1, 'Wireless Mouse', 'Electronics', '2026-03-01', 48),
(2, 'Mechanical Keyboard', 'Electronics', '2026-01-01', 30),
(2, 'Mechanical Keyboard', 'Electronics', '2026-02-01', 45),
(2, 'Mechanical Keyboard', 'Electronics', '2026-03-01', 60),
(3, 'USB-C Hub', 'Electronics', '2026-01-01', 20),
(3, 'USB-C Hub', 'Electronics', '2026-02-01', 25),
(3, 'USB-C Hub', 'Electronics', '2026-03-01', 35),
(4, 'Notebook', 'Stationery', '2026-01-01', 100),
(4, 'Notebook', 'Stationery', '2026-02-01', 90),
(4, 'Notebook', 'Stationery', '2026-03-01', 120),
(5, 'Pen Set', 'Stationery', '2026-01-01', 70),
(5, 'Pen Set', 'Stationery', '2026-02-01', 85),
(5, 'Pen Set', 'Stationery', '2026-03-01', 80),
(6, 'Marker Pack', 'Stationery', '2026-01-01', 40),
(6, 'Marker Pack', 'Stationery', '2026-02-01', 55),
(6, 'Marker Pack', 'Stationery', '2026-03-01', 65);
GO

/* 3. CTE + ROW_NUMBER + PARTITION BY: top three products by total units. */
WITH ProductTotals AS
(
    SELECT
        ProductID,
        ProductName,
        Category,
        SUM(UnitsSold) AS TotalUnitsSold
    FROM dbo.ProductSales
    GROUP BY ProductID, ProductName, Category
),
RankedProducts AS
(
    SELECT
        ProductID,
        ProductName,
        Category,
        TotalUnitsSold,
        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY TotalUnitsSold DESC, ProductID
        ) AS CategoryRow
    FROM ProductTotals
)
SELECT
    ProductID,
    ProductName,
    Category,
    TotalUnitsSold,
    CategoryRow
FROM RankedProducts
WHERE CategoryRow <= 3
ORDER BY Category, CategoryRow;
GO

/* 4. LAG/LEAD: month-on-month changes for each product. */
WITH MonthlyProductSales AS
(
    SELECT
        ProductID,
        ProductName,
        Category,
        SaleMonth,
        SUM(UnitsSold) AS MonthlyUnits
    FROM dbo.ProductSales
    GROUP BY ProductID, ProductName, Category, SaleMonth
),
SalesComparison AS
(
    SELECT
        ProductID,
        ProductName,
        Category,
        SaleMonth,
        MonthlyUnits,
        LAG(MonthlyUnits) OVER
        (
            PARTITION BY ProductID
            ORDER BY SaleMonth
        ) AS PreviousMonthUnits,
        LEAD(MonthlyUnits) OVER
        (
            PARTITION BY ProductID
            ORDER BY SaleMonth
        ) AS NextMonthUnits
    FROM MonthlyProductSales
)
SELECT
    ProductID,
    ProductName,
    Category,
    SaleMonth,
    MonthlyUnits,
    PreviousMonthUnits,
    MonthlyUnits - PreviousMonthUnits AS ChangeFromPreviousMonth,
    NextMonthUnits,
    NextMonthUnits - MonthlyUnits AS ChangeToNextMonth
FROM SalesComparison
ORDER BY ProductID, SaleMonth;
GO
