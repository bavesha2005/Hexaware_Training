CREATE DATABASE RetailInventoryDB;
GO
USE RetailInventoryDB;
GO

CREATE TABLE dbo.Categories (
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(80) NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName)
);

CREATE TABLE dbo.Suppliers (
    SupplierID    INT IDENTITY(1,1) NOT NULL,
    SupplierName  NVARCHAR(120) NOT NULL,
    SupplierPhone NVARCHAR(25) NOT NULL,
    CONSTRAINT PK_Suppliers PRIMARY KEY (SupplierID),
    CONSTRAINT UQ_Suppliers_Phone UNIQUE (SupplierPhone),
    CONSTRAINT CK_Suppliers_Phone_NotBlank CHECK (LEN(LTRIM(RTRIM(SupplierPhone))) > 0)
);

CREATE TABLE dbo.Warehouses (
    WarehouseID   INT IDENTITY(1,1) NOT NULL,
    WarehouseName NVARCHAR(100) NOT NULL,
    Location      NVARCHAR(150) NOT NULL,
    CONSTRAINT PK_Warehouses PRIMARY KEY (WarehouseID),
    CONSTRAINT UQ_Warehouses_Name UNIQUE (WarehouseName)
);

CREATE TABLE dbo.Products (
    SKU            VARCHAR(20) NOT NULL,
    ProductName    NVARCHAR(150) NOT NULL,
    CategoryID     INT NOT NULL,
    SupplierID     INT NOT NULL,
    IsDiscontinued BIT NOT NULL CONSTRAINT DF_Products_IsDiscontinued DEFAULT (0),
    CONSTRAINT PK_Products PRIMARY KEY (SKU),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID)
        REFERENCES dbo.Suppliers(SupplierID) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CK_Products_SKU_NotBlank CHECK (LEN(LTRIM(RTRIM(SKU))) > 0),
    CONSTRAINT CK_Products_Name_NotBlank CHECK (LEN(LTRIM(RTRIM(ProductName))) > 0)
);

CREATE TABLE dbo.Inventory (
    SKU          VARCHAR(20) NOT NULL,
    WarehouseID  INT NOT NULL,
    Quantity     INT NOT NULL CONSTRAINT DF_Inventory_Quantity DEFAULT (0),
    ReorderLevel INT NOT NULL CONSTRAINT DF_Inventory_ReorderLevel DEFAULT (5),
    CONSTRAINT PK_Inventory PRIMARY KEY (SKU, WarehouseID),
    CONSTRAINT FK_Inventory_Products FOREIGN KEY (SKU)
        REFERENCES dbo.Products(SKU) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Inventory_Warehouses FOREIGN KEY (WarehouseID)
        REFERENCES dbo.Warehouses(WarehouseID) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CK_Inventory_Quantity_NonNegative CHECK (Quantity >= 0),
    CONSTRAINT CK_Inventory_ReorderLevel_NonNegative CHECK (ReorderLevel >= 0)
);
GO

INSERT INTO dbo.Categories (CategoryName) VALUES
(N'Electronics'), (N'Home Appliances'), (N'Furniture'), (N'Stationery'), (N'Sports'),
(N'Kitchenware'), (N'Personal Care'), (N'Toys'), (N'Footwear'), (N'Accessories');

INSERT INTO dbo.Suppliers (SupplierName, SupplierPhone) VALUES
(N'Alpha Distributors', N'+91-9000000001'), (N'Bright Wholesale', N'+91-9000000002'),
(N'City Supply Co', N'+91-9000000003'), (N'Delta Traders', N'+91-9000000004'),
(N'Evergreen Imports', N'+91-9000000005'), (N'Future Retail Supply', N'+91-9000000006'),
(N'Global Goods', N'+91-9000000007'), (N'HomeNeeds Supplier', N'+91-9000000008'),
(N'Iconic Distributors', N'+91-9000000009'), (N'Jupiter Wholesale', N'+91-9000000010');

INSERT INTO dbo.Warehouses (WarehouseName, Location) VALUES
(N'Chennai Central', N'Chennai, Tamil Nadu'), (N'Coimbatore Hub', N'Coimbatore, Tamil Nadu'),
(N'Bengaluru North', N'Bengaluru, Karnataka'), (N'Hyderabad Depot', N'Hyderabad, Telangana'),
(N'Mumbai West', N'Mumbai, Maharashtra'), (N'Pune Storage', N'Pune, Maharashtra'),
(N'Delhi NCR', N'New Delhi, Delhi'), (N'Kochi Port', N'Kochi, Kerala'),
(N'Jaipur Store', N'Jaipur, Rajasthan'), (N'Kolkata East', N'Kolkata, West Bengal');

INSERT INTO dbo.Products (SKU, ProductName, CategoryID, SupplierID, IsDiscontinued) VALUES
('EL-1001', N'Wireless Mouse', 1, 1, 0), ('EL-1002', N'USB-C Hub', 1, 2, 0),
('HA-2001', N'Electric Kettle', 2, 3, 0), ('FU-3001', N'Office Chair', 3, 4, 0),
('ST-4001', N'Notebook Pack', 4, 5, 0), ('ST-4002', N'Gel Pen Set', 4, 5, 0),
('SP-5001', N'Yoga Mat', 5, 6, 0), ('KI-6001', N'Non-stick Pan', 6, 7, 0),
('PC-7001', N'Water Flosser', 7, 8, 0), ('TY-8001', N'Building Blocks Set', 8, 9, 0),
('FW-9101', N'Canvas Sneakers', 9, 10, 1), ('AC-9001', N'Leather Wallet', 10, 10, 1);

INSERT INTO dbo.Inventory (SKU, WarehouseID, Quantity, ReorderLevel) VALUES
('EL-1001', 1, 45, 10), ('EL-1001', 2, 15, 10), ('EL-1002', 1, 22, 6), ('HA-2001', 2, 18, 5),
('FU-3001', 3, 12, 3), ('ST-4001', 4, 100, 20), ('ST-4002', 4, 60, 15), ('SP-5001', 5, 30, 8),
('KI-6001', 6, 25, 7), ('PC-7001', 7, 14, 4), ('TY-8001', 8, 40, 10), ('FW-9101', 9, 3, 5),
('AC-9001', 1, 0, 2);
GO

BEGIN TRY
    INSERT INTO dbo.Products (SKU, ProductName, CategoryID, SupplierID) VALUES ('EL-1001', N'Duplicate Mouse', 1, 1);
END TRY
BEGIN CATCH
    SELECT 'Duplicate key' AS Test, ERROR_NUMBER() AS ErrorNo, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Products (SKU, ProductName, CategoryID, SupplierID) VALUES ('XX-0001', N'Orphan Product', 99, 1);
END TRY
BEGIN CATCH
    SELECT 'Missing parent' AS Test, ERROR_NUMBER() AS ErrorNo, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Inventory (SKU, WarehouseID, Quantity, ReorderLevel) VALUES ('EL-1002', 2, -5, 6);
END TRY
BEGIN CATCH
    SELECT 'Negative quantity' AS Test, ERROR_NUMBER() AS ErrorNo, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Suppliers (SupplierName, SupplierPhone) VALUES (NULL, N'+91-9000000011');
END TRY
BEGIN CATCH
    SELECT 'NULL in mandatory column' AS Test, ERROR_NUMBER() AS ErrorNo, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT SupplierID, SupplierName, SupplierPhone FROM dbo.Suppliers WHERE SupplierID = 1;

UPDATE dbo.Suppliers
SET SupplierPhone = N'+91-9888888001'
WHERE SupplierID = 1;

SELECT SupplierID, SupplierName, SupplierPhone FROM dbo.Suppliers WHERE SupplierID = 1;

SELECT p.SKU, p.ProductName, p.IsDiscontinued, i.WarehouseID, i.Quantity
FROM dbo.Products AS p
LEFT JOIN dbo.Inventory AS i ON i.SKU = p.SKU
WHERE p.IsDiscontinued = 1;

DELETE FROM dbo.Products
WHERE IsDiscontinued = 1;

SELECT p.SKU, p.ProductName, p.IsDiscontinued, i.WarehouseID, i.Quantity
FROM dbo.Products AS p
LEFT JOIN dbo.Inventory AS i ON i.SKU = p.SKU
WHERE p.IsDiscontinued = 1;

SELECT (SELECT COUNT(*) FROM dbo.Products) AS ProductsLeft,
       (SELECT COUNT(*) FROM dbo.Inventory) AS InventoryRowsLeft;
