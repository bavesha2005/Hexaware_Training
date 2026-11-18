IF DB_ID(N'RetailReturnsRefunds') IS NULL
    CREATE DATABASE RetailReturnsRefunds;
GO

USE RetailReturnsRefunds;
GO

IF OBJECT_ID(N'dbo.ReturnsFeedback', N'U') IS NOT NULL DROP TABLE dbo.ReturnsFeedback;
IF OBJECT_ID(N'dbo.Refunds', N'U') IS NOT NULL DROP TABLE dbo.Refunds;
IF OBJECT_ID(N'dbo.Returns', N'U') IS NOT NULL DROP TABLE dbo.Returns;
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID(N'dbo.Stores', N'U') IS NOT NULL DROP TABLE dbo.Stores;
GO

CREATE TABLE dbo.Stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

CREATE TABLE dbo.Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(60) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    store_id INT NOT NULL,
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (manager_id) REFERENCES dbo.Employees(employee_id),
    CONSTRAINT FK_Employees_Store FOREIGN KEY (store_id) REFERENCES dbo.Stores(store_id)
);

CREATE TABLE dbo.Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    CONSTRAINT FK_Orders_Store FOREIGN KEY (store_id) REFERENCES dbo.Stores(store_id)
);

CREATE TABLE dbo.OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);

CREATE TABLE dbo.Returns (
    return_id INT PRIMARY KEY,
    order_item_id INT NOT NULL,
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL,
    return_reason VARCHAR(150),
    CONSTRAINT FK_Returns_OrderItem FOREIGN KEY (order_item_id) REFERENCES dbo.OrderItems(order_item_id),
    CONSTRAINT FK_Returns_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    CONSTRAINT FK_Returns_Store FOREIGN KEY (store_id) REFERENCES dbo.Stores(store_id)
);

CREATE TABLE dbo.Refunds (
    refund_id INT PRIMARY KEY,
    return_id INT NOT NULL,
    refund_date DATE NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_status VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Refunds_Return FOREIGN KEY (return_id) REFERENCES dbo.Returns(return_id)
);

CREATE TABLE dbo.ReturnsFeedback (
    feedback_id INT PRIMARY KEY,
    return_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    feedback_text VARCHAR(500),
    feedback_date DATE NOT NULL,
    CONSTRAINT FK_ReturnsFeedback_Return FOREIGN KEY (return_id) REFERENCES dbo.Returns(return_id),
    CONSTRAINT FK_ReturnsFeedback_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
);
GO

INSERT INTO dbo.Stores (store_id, store_name, region, city) VALUES
(1, 'Chennai Central', 'South', 'Chennai'),
(2, 'Bengaluru Square', 'South', 'Bengaluru'),
(3, 'Hyderabad Mall', 'South', 'Hyderabad'),
(4, 'Mumbai High Street', 'West', 'Mumbai'),
(5, 'Pune Market', 'West', 'Pune'),
(6, 'Delhi City Centre', 'North', 'Delhi');

INSERT INTO dbo.Customers (customer_id, customer_name, email) VALUES
(101, 'Aarav Menon', 'aarav@example.com'),
(102, 'Diya Sharma', 'diya@example.com'),
(103, 'Kabir Rao', 'kabir@example.com'),
(104, 'Ananya Iyer', 'ananya@example.com'),
(105, 'Ishaan Patel', 'ishaan@example.com'),
(106, 'Mira Das', 'mira@example.com');

INSERT INTO dbo.Products (product_id, product_name, category, unit_price) VALUES
(201, 'Wireless Headphones', 'Electronics', 2500.00),
(202, 'Running Shoes', 'Footwear', 3200.00),
(203, 'Coffee Maker', 'Home Appliances', 4500.00),
(204, 'Backpack', 'Accessories', 1800.00),
(205, 'Smart Watch', 'Electronics', 6000.00),
(206, 'Yoga Mat', 'Fitness', 900.00);

INSERT INTO dbo.Employees (employee_id, employee_name, manager_id, store_id) VALUES
(1, 'Ritika', NULL, 1),
(2, 'Sanjay', 1, 1),
(3, 'Naveen', 1, 2),
(4, 'Pooja', 3, 2),
(5, 'Farhan', 2, 3),
(6, 'Leena', NULL, 4);

INSERT INTO dbo.Orders (order_id, customer_id, store_id, order_date) VALUES
(1001, 101, 1, '2026-09-01'),
(1002, 102, 1, '2026-09-03'),
(1003, 103, 2, '2026-09-05'),
(1004, 104, 2, '2026-09-07'),
(1005, 101, 3, '2026-09-09'),
(1006, 105, 4, '2026-09-11'),
(1007, 106, 4, '2026-09-13'),
(1008, 102, 5, '2026-09-15'),
(1009, 103, 6, '2026-09-17'),
(1010, 104, 1, '2026-09-19'),
(1011, 105, 2, '2026-09-21'),
(1012, 106, 3, '2026-09-23');

INSERT INTO dbo.OrderItems (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 201, 2, 2500),
(2, 1002, 202, 1, 3200),
(3, 1003, 201, 1, 2500),
(4, 1004, 203, 1, 4500),
(5, 1005, 204, 2, 1800),
(6, 1006, 205, 1, 6000),
(7, 1007, 202, 2, 3200),
(8, 1008, 201, 1, 2500),
(9, 1009, 206, 3, 900),
(10, 1010, 205, 1, 6000),
(11, 1011, 203, 1, 4500),
(12, 1012, 204, 1, 1800),
(13, 1001, 206, 1, 900),
(14, 1003, 202, 1, 3200);

INSERT INTO dbo.Returns
(return_id, order_item_id, customer_id, store_id, return_date, return_quantity, return_reason)
VALUES
(301, 1, 101, 1, '2026-09-10', 1, 'Defective'),
(302, 2, 102, 1, '2026-09-12', 1, 'Wrong size'),
(303, 3, 103, 2, '2026-09-15', 1, 'Defective'),
(304, 4, 104, 2, '2026-09-17', 1, 'Changed mind'),
(305, 5, 101, 3, '2026-09-20', 1, 'Damaged'),
(306, 6, 105, 4, '2026-09-22', 1, 'Not as described'),
(307, 7, 106, 4, '2026-09-24', 1, 'Wrong size'),
(308, 8, 102, 5, '2026-09-26', 1, 'Defective'),
(309, 9, 103, 6, '2026-09-28', 1, 'Changed mind'),
(310, 10, 104, 1, '2026-10-01', 1, 'Defective'),
(311, 11, 105, 2, '2026-10-03', 1, 'Damaged');

INSERT INTO dbo.Refunds (refund_id, return_id, refund_date, refund_amount, refund_status) VALUES
(401, 301, '2026-09-11', 2500, 'Completed'),
(402, 302, '2026-09-13', 3200, 'Completed'),
(403, 303, '2026-09-16', 2500, 'Completed'),
(404, 305, '2026-09-21', 1800, 'Completed'),
(405, 306, '2026-09-23', 6000, 'Completed'),
(406, 308, '2026-09-27', 2500, 'Completed'),
(407, 309, '2026-09-29', 900, 'Completed'),
(408, 310, '2026-10-02', 6000, 'Pending');

INSERT INTO dbo.ReturnsFeedback (feedback_id, return_id, customer_id, rating, feedback_text, feedback_date) VALUES
(501, 301, 101, 2, 'Product stopped working', '2026-09-12'),
(502, 302, 102, 3, 'Size was not suitable', '2026-09-14'),
(503, 303, 103, 1, 'Received a faulty item', '2026-09-17'),
(504, 305, 101, 2, 'Package was damaged', '2026-09-22'),
(505, 306, 105, 2, 'Product did not match description', '2026-09-24'),
(506, 308, 102, 1, 'Device would not switch on', '2026-09-28'),
(507, 310, 104, 2, 'Watch was defective', '2026-10-03');
GO

SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS units_sold,
       COALESCE(SUM(r.return_quantity), 0) AS units_returned,
       CAST(100.0 * COALESCE(SUM(r.return_quantity), 0) / NULLIF(SUM(oi.quantity), 0) AS DECIMAL(6,2)) AS return_rate_percent
FROM dbo.Products p
INNER JOIN dbo.OrderItems oi ON oi.product_id = p.product_id
LEFT JOIN dbo.Returns r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_id, p.product_name
HAVING 100.0 * COALESCE(SUM(r.return_quantity), 0) / NULLIF(SUM(oi.quantity), 0) > 10;

SELECT DISTINCT c.customer_id, c.customer_name
FROM dbo.Customers c
INNER JOIN dbo.Returns r ON r.customer_id = c.customer_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
WHERE rf.refund_id IS NULL;

SELECT s.store_id, s.store_name,
       COALESCE(SUM(CASE WHEN rf.refund_status = 'Completed' THEN rf.refund_amount ELSE 0 END), 0) AS completed_refund_value
FROM dbo.Stores s
LEFT JOIN dbo.Returns r ON r.store_id = s.store_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
GROUP BY s.store_id, s.store_name
ORDER BY completed_refund_value DESC;

SELECT e.employee_name AS employee,
       COALESCE(m.employee_name, 'No manager') AS manager,
       s.store_name
FROM dbo.Employees e
LEFT JOIN dbo.Employees m ON m.employee_id = e.manager_id
INNER JOIN dbo.Stores s ON s.store_id = e.store_id;

SELECT p.product_name, COUNT(DISTINCT r.return_id) AS return_count,
       SUM(r.return_quantity) AS units_returned
FROM dbo.Products p
INNER JOIN dbo.OrderItems oi ON oi.product_id = p.product_id
INNER JOIN dbo.Returns r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_name;

SELECT c.customer_name, COUNT(DISTINCT r.return_id) AS return_count,
       COALESCE(SUM(rf.refund_amount), 0) AS refund_value
FROM dbo.Customers c
LEFT JOIN dbo.Returns r ON r.customer_id = c.customer_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
GROUP BY c.customer_name;

SELECT s.store_name, COUNT(DISTINCT r.return_id) AS return_count,
       COALESCE(SUM(r.return_quantity), 0) AS units_returned
FROM dbo.Stores s
LEFT JOIN dbo.Returns r ON r.store_id = s.store_id
GROUP BY s.store_name;

SELECT r.return_id, c.customer_name, p.product_name,
       rf.refund_amount, rf.refund_status
FROM dbo.Returns r
INNER JOIN dbo.Customers c ON c.customer_id = r.customer_id
INNER JOIN dbo.OrderItems oi ON oi.order_item_id = r.order_item_id
INNER JOIN dbo.Products p ON p.product_id = oi.product_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id;

SELECT p.product_name, AVG(CAST(f.rating AS DECIMAL(5,2))) AS average_feedback_rating,
       COUNT(f.feedback_id) AS feedback_count
FROM dbo.Products p
INNER JOIN dbo.OrderItems oi ON oi.product_id = p.product_id
INNER JOIN dbo.Returns r ON r.order_item_id = oi.order_item_id
INNER JOIN dbo.ReturnsFeedback f ON f.return_id = r.return_id
GROUP BY p.product_name;

SELECT c.customer_name, r.return_id, r.return_date, r.return_reason
FROM dbo.Customers c
INNER JOIN dbo.Returns r ON r.customer_id = c.customer_id
WHERE r.return_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE));

SELECT customer_id, customer_name
FROM dbo.Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM dbo.Returns
);

SELECT customer_id, customer_name
FROM dbo.Customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM dbo.Returns
    UNION ALL
    SELECT CAST(NULL AS INT)
);

SELECT c.customer_id, c.customer_name
FROM dbo.Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Returns r
    WHERE r.customer_id = c.customer_id
);

SELECT s.store_id, s.store_name, s.region,
       COALESCE(SUM(rf.refund_amount), 0) AS store_refund_total
FROM dbo.Stores s
LEFT JOIN dbo.Returns r ON r.store_id = s.store_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
GROUP BY s.store_id, s.store_name, s.region
HAVING COALESCE(SUM(rf.refund_amount), 0) > ANY (
    SELECT COALESCE(SUM(rf2.refund_amount), 0)
    FROM dbo.Stores s2
    LEFT JOIN dbo.Returns r2 ON r2.store_id = s2.store_id
    LEFT JOIN dbo.Refunds rf2 ON rf2.return_id = r2.return_id
    WHERE s2.region = s.region
      AND s2.store_id <> s.store_id
    GROUP BY s2.store_id
);

SELECT s.store_id, s.store_name, s.region,
       COALESCE(SUM(rf.refund_amount), 0) AS store_refund_total
FROM dbo.Stores s
LEFT JOIN dbo.Returns r ON r.store_id = s.store_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
GROUP BY s.store_id, s.store_name, s.region
HAVING COALESCE(SUM(rf.refund_amount), 0) > ALL (
    SELECT COALESCE(SUM(rf2.refund_amount), 0)
    FROM dbo.Stores s2
    LEFT JOIN dbo.Returns r2 ON r2.store_id = s2.store_id
    LEFT JOIN dbo.Refunds rf2 ON rf2.return_id = r2.return_id
    WHERE s2.region = s.region
      AND s2.store_id <> s.store_id
    GROUP BY s2.store_id
);

SELECT p.product_name, product_returns.returned_units, product_sales.sold_units,
       CAST(100.0 * product_returns.returned_units / NULLIF(product_sales.sold_units, 0) AS DECIMAL(6,2)) AS return_rate_percent
FROM dbo.Products p
INNER JOIN (
    SELECT oi.product_id, SUM(r.return_quantity) AS returned_units
    FROM dbo.OrderItems oi
    INNER JOIN dbo.Returns r ON r.order_item_id = oi.order_item_id
    GROUP BY oi.product_id
) AS product_returns ON product_returns.product_id = p.product_id
INNER JOIN (
    SELECT product_id, SUM(quantity) AS sold_units
    FROM dbo.OrderItems
    GROUP BY product_id
) AS product_sales ON product_sales.product_id = p.product_id
WHERE product_returns.returned_units > (
    SELECT AVG(returned_by_product)
    FROM (
        SELECT SUM(r2.return_quantity) AS returned_by_product
        FROM dbo.OrderItems oi2
        INNER JOIN dbo.Returns r2 ON r2.order_item_id = oi2.order_item_id
        GROUP BY oi2.product_id
    ) AS product_return_totals
);

SELECT s.store_name, refund_totals.refund_total
FROM dbo.Stores s
INNER JOIN (
    SELECT r.store_id, SUM(rf.refund_amount) AS refund_total
    FROM dbo.Returns r
    INNER JOIN dbo.Refunds rf ON rf.return_id = r.return_id
    WHERE rf.refund_status = 'Completed'
    GROUP BY r.store_id
) AS refund_totals ON refund_totals.store_id = s.store_id
WHERE refund_totals.refund_total > (
    SELECT AVG(store_refund_total)
    FROM (
        SELECT r2.store_id, SUM(rf2.refund_amount) AS store_refund_total
        FROM dbo.Returns r2
        INNER JOIN dbo.Refunds rf2 ON rf2.return_id = r2.return_id
        WHERE rf2.refund_status = 'Completed'
        GROUP BY r2.store_id
    ) AS store_refund_averages
);

SELECT s.store_name, s.region,
       COALESCE(SUM(rf.refund_amount), 0) AS completed_refund_value
FROM dbo.Stores s
LEFT JOIN dbo.Returns r ON r.store_id = s.store_id
LEFT JOIN dbo.Refunds rf ON rf.return_id = r.return_id
    AND rf.refund_status = 'Completed'
GROUP BY s.store_name, s.region
ORDER BY s.region, completed_refund_value DESC;
