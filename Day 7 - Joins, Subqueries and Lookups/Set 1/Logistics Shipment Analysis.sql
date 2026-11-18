IF DB_ID(N'LogisticsShipmentAnalysis') IS NULL
    CREATE DATABASE LogisticsShipmentAnalysis;
GO

USE LogisticsShipmentAnalysis;
GO

IF OBJECT_ID(N'dbo.DeliveryEvents', N'U') IS NOT NULL DROP TABLE dbo.DeliveryEvents;
IF OBJECT_ID(N'dbo.Shipments', N'U') IS NOT NULL DROP TABLE dbo.Shipments;
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID(N'dbo.Carriers', N'U') IS NOT NULL DROP TABLE dbo.Carriers;
IF OBJECT_ID(N'dbo.Hubs', N'U') IS NOT NULL DROP TABLE dbo.Hubs;
GO

CREATE TABLE dbo.Hubs (
    hub_id INT PRIMARY KEY,
    hub_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Carriers (
    carrier_id INT PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

CREATE TABLE dbo.Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    supervisor_id INT NULL,
    hub_id INT NOT NULL,
    CONSTRAINT FK_Employees_Supervisor FOREIGN KEY (supervisor_id) REFERENCES dbo.Employees(employee_id),
    CONSTRAINT FK_Employees_Hub FOREIGN KEY (hub_id) REFERENCES dbo.Hubs(hub_id)
);

CREATE TABLE dbo.Shipments (
    shipment_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    carrier_id INT NOT NULL,
    origin_hub_id INT NOT NULL,
    destination_hub_id INT NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    shipment_date DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    actual_delivery_date DATE NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Shipments_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    CONSTRAINT FK_Shipments_Carrier FOREIGN KEY (carrier_id) REFERENCES dbo.Carriers(carrier_id),
    CONSTRAINT FK_Shipments_OriginHub FOREIGN KEY (origin_hub_id) REFERENCES dbo.Hubs(hub_id),
    CONSTRAINT FK_Shipments_DestinationHub FOREIGN KEY (destination_hub_id) REFERENCES dbo.Hubs(hub_id)
);

CREATE TABLE dbo.DeliveryEvents (
    event_id INT PRIMARY KEY,
    shipment_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_location VARCHAR(100) NOT NULL,
    event_time DATETIME2 NOT NULL,
    event_notes VARCHAR(250),
    CONSTRAINT FK_DeliveryEvents_Shipment FOREIGN KEY (shipment_id) REFERENCES dbo.Shipments(shipment_id)
);
GO

INSERT INTO dbo.Hubs (hub_id, hub_name, city) VALUES
(1, 'Chennai Central', 'Chennai'),
(2, 'Bengaluru Hub', 'Bengaluru'),
(3, 'Hyderabad Hub', 'Hyderabad'),
(4, 'Mumbai Hub', 'Mumbai'),
(5, 'Kochi Hub', 'Kochi');

INSERT INTO dbo.Carriers (carrier_id, carrier_name) VALUES
(1, 'SwiftMove'),
(2, 'BlueRoute'),
(3, 'RapidHaul');

INSERT INTO dbo.Customers (customer_id, customer_name, email) VALUES
(1, 'Aarav Stores', 'aarav@example.com'),
(2, 'Nila Traders', 'nila@example.com'),
(3, 'Orbit Retail', 'orbit@example.com'),
(4, 'GreenCart', 'green@example.com');

INSERT INTO dbo.Employees (employee_id, employee_name, supervisor_id, hub_id) VALUES
(1, 'Meera', NULL, 1),
(2, 'Karthik', 1, 1),
(3, 'Divya', 1, 2),
(4, 'Rahul', 2, 3),
(5, 'Ananya', 3, 4);

INSERT INTO dbo.Shipments
(shipment_id, customer_id, carrier_id, origin_hub_id, destination_hub_id, shipping_cost, shipment_date, expected_delivery_date, actual_delivery_date, status)
VALUES
(1001, 1, 1, 1, 2, 850.00, '2026-10-01', '2026-10-04', '2026-10-08', 'Delivered'),
(1002, 1, 2, 2, 3, 620.00, '2026-10-03', '2026-10-06', '2026-10-06', 'Delivered'),
(1003, 1, 3, 3, 4, 950.00, '2026-10-05', '2026-10-09', '2026-10-13', 'Delivered'),
(1004, 1, 1, 4, 5, 700.00, '2026-10-07', '2026-10-10', '2026-10-10', 'Delivered'),
(1005, 2, 2, 1, 3, 540.00, '2026-10-08', '2026-10-11', '2026-10-12', 'Delivered'),
(1006, 2, 3, 3, 2, 680.00, '2026-10-10', '2026-10-13', '2026-10-18', 'Delivered'),
(1007, 3, 1, 2, 4, 1100.00, '2026-10-12', '2026-10-16', NULL, 'In Transit'),
(1008, 3, 2, 4, 1, 760.00, '2026-10-14', '2026-10-17', '2026-10-17', 'Delivered'),
(1009, 4, 3, 1, 2, 490.00, '2026-10-15', '2026-10-18', '2026-10-22', 'Delivered'),
(1010, 2, 1, 2, 5, 880.00, '2026-10-16', '2026-10-20', '2026-10-20', 'Delivered');

INSERT INTO dbo.DeliveryEvents (event_id, shipment_id, event_type, event_location, event_time, event_notes) VALUES
(1, 1001, 'Picked Up', 'Chennai', '2026-10-01T09:00:00', 'Shipment collected'),
(2, 1001, 'In Transit', 'Bengaluru', '2026-10-05T11:00:00', 'Arrived at transit hub'),
(3, 1001, 'Delivered', 'Bengaluru', '2026-10-08T15:30:00', 'Delivered to customer'),
(4, 1002, 'Delivered', 'Hyderabad', '2026-10-06T14:00:00', 'Delivered on schedule'),
(5, 1003, 'Delayed', 'Mumbai', '2026-10-11T10:00:00', 'Vehicle breakdown'),
(6, 1003, 'Delivered', 'Mumbai', '2026-10-13T16:00:00', 'Delivered late'),
(7, 1005, 'Delivered', 'Hyderabad', '2026-10-12T12:00:00', 'Delivered one day late'),
(8, 1006, 'Delayed', 'Bengaluru', '2026-10-16T08:00:00', 'Weather disruption'),
(9, 1006, 'Delivered', 'Bengaluru', '2026-10-18T17:00:00', 'Delivered late'),
(10, 1008, 'Delivered', 'Chennai', '2026-10-17T13:00:00', 'Delivered on schedule'),
(11, 1009, 'Delayed', 'Bengaluru', '2026-10-20T09:00:00', 'Sorting delay'),
(12, 1009, 'Delivered', 'Bengaluru', '2026-10-22T18:00:00', 'Delivered late'),
(13, 1010, 'Delivered', 'Kochi', '2026-10-20T11:00:00', 'Delivered on schedule');
GO

SELECT s.shipment_id, c.customer_name, ca.carrier_name,
       DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS delay_days
FROM dbo.Shipments s
INNER JOIN dbo.Customers c ON c.customer_id = s.customer_id
INNER JOIN dbo.Carriers ca ON ca.carrier_id = s.carrier_id
WHERE s.actual_delivery_date > DATEADD(DAY, 2, s.expected_delivery_date);

SELECT h.hub_id, h.hub_name
FROM dbo.Hubs h
LEFT JOIN dbo.Shipments s ON s.origin_hub_id = h.hub_id
WHERE s.shipment_id IS NULL;

SELECT e.employee_name AS employee,
       COALESCE(m.employee_name, 'No supervisor') AS supervisor,
       h.hub_name
FROM dbo.Employees e
LEFT JOIN dbo.Employees m ON m.employee_id = e.supervisor_id
INNER JOIN dbo.Hubs h ON h.hub_id = e.hub_id;

SELECT h.hub_name, s.shipment_id, s.status
FROM dbo.Hubs h
FULL OUTER JOIN dbo.Shipments s ON s.origin_hub_id = h.hub_id
ORDER BY h.hub_name, s.shipment_id;

SELECT s.shipment_id, c.customer_name, ca.carrier_name,
       oh.hub_name AS origin_hub, dh.hub_name AS destination_hub
FROM dbo.Shipments s
INNER JOIN dbo.Customers c ON c.customer_id = s.customer_id
INNER JOIN dbo.Carriers ca ON ca.carrier_id = s.carrier_id
INNER JOIN dbo.Hubs oh ON oh.hub_id = s.origin_hub_id
INNER JOIN dbo.Hubs dh ON dh.hub_id = s.destination_hub_id;

SELECT ca.carrier_name, COUNT(*) AS shipment_count
FROM dbo.Carriers ca
LEFT JOIN dbo.Shipments s ON s.carrier_id = ca.carrier_id
GROUP BY ca.carrier_name;

SELECT h.hub_name, COUNT(s.shipment_id) AS outbound_shipments
FROM dbo.Hubs h
LEFT JOIN dbo.Shipments s ON s.origin_hub_id = h.hub_id
GROUP BY h.hub_name;

SELECT s.shipment_id, s.status, COUNT(de.event_id) AS event_count
FROM dbo.Shipments s
LEFT JOIN dbo.DeliveryEvents de ON de.shipment_id = s.shipment_id
GROUP BY s.shipment_id, s.status
ORDER BY s.shipment_id;

SELECT c.customer_name, s.shipment_id, s.shipping_cost
FROM dbo.Customers c
INNER JOIN dbo.Shipments s ON s.customer_id = c.customer_id
WHERE s.shipping_cost > (SELECT AVG(s2.shipping_cost)
                         FROM dbo.Shipments s2
                         WHERE s2.customer_id = c.customer_id);

SELECT h.hub_name, COUNT(s.shipment_id) AS inbound_shipments
FROM dbo.Hubs h
LEFT JOIN dbo.Shipments s ON s.destination_hub_id = h.hub_id
GROUP BY h.hub_name;

SELECT c.customer_id, c.customer_name
FROM dbo.Customers c
WHERE c.customer_id IN (
    SELECT s.customer_id
    FROM dbo.Shipments s
    GROUP BY s.customer_id
    HAVING COUNT(DISTINCT s.destination_hub_id) = (SELECT COUNT(*) FROM dbo.Hubs)
);

SELECT c.customer_id, c.customer_name
FROM dbo.Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Hubs h
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Shipments s
        WHERE s.customer_id = c.customer_id
          AND s.destination_hub_id = h.hub_id
    )
);

SELECT ca.carrier_name,
       AVG(CAST(DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS DECIMAL(10,2))) AS average_delay_days
FROM dbo.Carriers ca
INNER JOIN dbo.Shipments s ON s.carrier_id = ca.carrier_id
WHERE s.actual_delivery_date IS NOT NULL
GROUP BY ca.carrier_name
HAVING AVG(CAST(DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS DECIMAL(10,2))) >
       (SELECT AVG(CAST(DATEDIFF(DAY, expected_delivery_date, actual_delivery_date) AS DECIMAL(10,2)))
        FROM dbo.Shipments
        WHERE actual_delivery_date IS NOT NULL);

SELECT ca.carrier_name
FROM dbo.Carriers ca
WHERE (SELECT AVG(CAST(DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS DECIMAL(10,2)))
       FROM dbo.Shipments s
       WHERE s.carrier_id = ca.carrier_id AND s.actual_delivery_date IS NOT NULL)
      > ALL (
          SELECT AVG(CAST(DATEDIFF(DAY, s2.expected_delivery_date, s2.actual_delivery_date) AS DECIMAL(10,2)))
          FROM dbo.Shipments s2
          WHERE s2.carrier_id <> ca.carrier_id AND s2.actual_delivery_date IS NOT NULL
          GROUP BY s2.carrier_id
      );

SELECT s.shipment_id, s.shipping_cost
FROM dbo.Shipments s
WHERE s.shipping_cost > ANY (
    SELECT s2.shipping_cost
    FROM dbo.Shipments s2
    WHERE s2.origin_hub_id = s.origin_hub_id
      AND s2.shipment_id <> s.shipment_id
);

SELECT c.customer_name, s.shipment_id
FROM dbo.Customers c
INNER JOIN dbo.Shipments s ON s.customer_id = c.customer_id
WHERE EXISTS (
    SELECT 1
    FROM dbo.DeliveryEvents de
    WHERE de.shipment_id = s.shipment_id
      AND de.event_type = 'Delayed'
);

SELECT s.shipment_id, ca.carrier_name, s.shipping_cost
FROM dbo.Shipments s
INNER JOIN dbo.Carriers ca ON ca.carrier_id = s.carrier_id
WHERE s.shipping_cost > (SELECT AVG(s2.shipping_cost) FROM dbo.Shipments s2 WHERE s2.carrier_id = s.carrier_id);

SELECT ca.carrier_name, AVG(s.shipping_cost) AS average_shipping_cost
FROM dbo.Carriers ca
INNER JOIN dbo.Shipments s ON s.carrier_id = ca.carrier_id
GROUP BY ca.carrier_name
HAVING AVG(s.shipping_cost) > (
    SELECT AVG(shipping_cost)
    FROM dbo.Shipments
);

WITH RankedHubCosts AS (
    SELECT origin_hub_id, shipping_cost,
           DENSE_RANK() OVER (PARTITION BY origin_hub_id ORDER BY shipping_cost DESC) AS cost_rank
    FROM dbo.Shipments
)
SELECT h.hub_name, r.shipping_cost AS second_highest_shipping_cost
FROM RankedHubCosts r
INNER JOIN dbo.Hubs h ON h.hub_id = r.origin_hub_id
WHERE r.cost_rank = 2;

SELECT s.shipment_id, s.shipping_cost
FROM dbo.Shipments s
WHERE s.shipping_cost = (
    SELECT MAX(s1.shipping_cost)
    FROM dbo.Shipments s1
    WHERE s1.origin_hub_id = s.origin_hub_id
      AND s1.shipping_cost < (
          SELECT MAX(s2.shipping_cost)
          FROM dbo.Shipments s2
          WHERE s2.origin_hub_id = s.origin_hub_id
      )
);
