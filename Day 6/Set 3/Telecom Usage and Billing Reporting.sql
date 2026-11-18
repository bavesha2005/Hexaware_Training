CREATE DATABASE TelecomDB;
GO
USE TelecomDB;
GO

CREATE TABLE dbo.plans (
    PlanID      INT IDENTITY(1,1) PRIMARY KEY,
    PlanName    NVARCHAR(50) NOT NULL,
    MonthlyFee  DECIMAL(10,2) NOT NULL,
    DataLimitMB DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.subscribers (
    SubscriberID   INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberName NVARCHAR(80) NOT NULL,
    Circle         NVARCHAR(40) NOT NULL,
    PlanID         INT NOT NULL REFERENCES dbo.plans(PlanID)
);

CREATE TABLE dbo.call_records (
    CallID       INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberID INT NOT NULL REFERENCES dbo.subscribers(SubscriberID),
    CallDate     DATE NOT NULL,
    DurationMin  INT NULL,
    DataUsedMB   DECIMAL(10,2) NULL
);

CREATE TABLE dbo.invoices (
    InvoiceID    INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberID INT NOT NULL REFERENCES dbo.subscribers(SubscriberID),
    InvoiceDate  DATE NOT NULL,
    DueDate      DATE NOT NULL,
    Amount       DECIMAL(10,2) NOT NULL,
    PaidDate     DATE NULL
);
GO

INSERT INTO dbo.plans (PlanName, MonthlyFee, DataLimitMB) VALUES
(N'Basic', 199, 2000), (N'Standard', 399, 5000), (N'Premium', 699, 15000), (N'Elite', 999, 30000);

INSERT INTO dbo.subscribers (SubscriberName, Circle, PlanID) VALUES
(N'Arun', N'Tamil Nadu', 2), (N'Divya', N'Tamil Nadu', 1), (N'Karthik', N'Tamil Nadu', 3),
(N'Meena', N'Karnataka', 2), (N'Rahul', N'Karnataka', 1), (N'Sneha', N'Kerala', 3),
(N'Vikram', N'Kerala', 2), (N'Priya', N'Maharashtra', 4), (N'Suresh', N'Maharashtra', 1),
(N'Lakshmi', N'Tamil Nadu', 2), (N'Naveen', N'Karnataka', 3), (N'Anitha', N'Kerala', 1),
(N'Ganesh', N'Tamil Nadu', 1), (N'Hari', N'Karnataka', 1);

INSERT INTO dbo.call_records (SubscriberID, CallDate, DurationMin, DataUsedMB) VALUES
(1, '2026-11-02', 45, NULL), (1, '2026-11-05', 30, NULL), (1, '2026-11-03', NULL, 3200), (1, '2026-11-10', NULL, 2100),
(2, '2026-11-04', 20, NULL), (2, '2026-11-06', NULL, 1500),
(3, '2026-11-01', 120, NULL), (3, '2026-11-08', 60, NULL), (3, '2026-11-02', NULL, 9000), (3, '2026-11-09', NULL, 4000),
(4, '2026-11-03', 80, NULL), (4, '2026-11-05', NULL, 6100),
(5, '2026-11-07', 15, NULL), (5, '2026-11-07', NULL, 2600),
(6, '2026-11-02', 200, NULL), (6, '2026-11-04', NULL, 14000),
(7, '2026-11-09', NULL, 800), (7, '2026-11-09', 10, NULL),
(8, '2026-11-06', 150, NULL), (8, '2026-11-08', NULL, 21000), (8, '2026-11-12', NULL, 8500),
(9, '2026-11-10', 5, NULL), (9, '2026-11-11', NULL, 2400),
(12, '2026-11-12', 40, NULL),
(13, '2026-11-13', NULL, 500),
(14, '2026-11-14', NULL, 300);

INSERT INTO dbo.invoices (SubscriberID, InvoiceDate, DueDate, Amount, PaidDate)
SELECT s.SubscriberID, m.d, DATEADD(DAY, 20, m.d), p.MonthlyFee,
       CASE WHEN m.d = '2026-11-01' THEN NULL
            WHEN s.SubscriberID = 5 THEN NULL
            WHEN s.SubscriberID IN (9, 14) AND m.d = '2026-10-01' THEN NULL
            ELSE DATEADD(DAY, 5, m.d) END
FROM dbo.subscribers AS s
JOIN dbo.plans AS p ON p.PlanID = s.PlanID
CROSS JOIN (VALUES (CAST('2026-09-01' AS DATE)), (CAST('2026-10-01' AS DATE)), (CAST('2026-11-01' AS DATE))) AS m(d)
ORDER BY m.d, s.SubscriberID;
GO

DECLARE @Today DATE = '2026-11-18';

SELECT p.PlanName, SUM(cr.DurationMin) AS TotalCallMinutes
FROM dbo.plans AS p
JOIN dbo.subscribers AS s ON s.PlanID = p.PlanID
JOIN dbo.call_records AS cr ON cr.SubscriberID = s.SubscriberID
GROUP BY p.PlanName
ORDER BY TotalCallMinutes DESC;

SELECT s.SubscriberName, p.PlanName, p.DataLimitMB, SUM(cr.DataUsedMB) AS DataUsedMB,
       SUM(cr.DataUsedMB) - p.DataLimitMB AS ExcessMB
FROM dbo.subscribers AS s
JOIN dbo.plans AS p ON p.PlanID = s.PlanID
JOIN dbo.call_records AS cr ON cr.SubscriberID = s.SubscriberID
GROUP BY s.SubscriberName, p.PlanName, p.DataLimitMB
HAVING SUM(cr.DataUsedMB) > p.DataLimitMB
ORDER BY ExcessMB DESC;

SELECT FORMAT(InvoiceDate, 'yyyy-MM') AS InvoiceMonth,
       SUM(Amount) AS Billed,
       SUM(CASE WHEN PaidDate IS NOT NULL THEN Amount ELSE 0 END) AS Collected
FROM dbo.invoices
GROUP BY FORMAT(InvoiceDate, 'yyyy-MM')
ORDER BY InvoiceMonth;

SELECT CONCAT('INV-', FORMAT(i.InvoiceDate, 'yyyyMM'), '-', RIGHT(CONCAT('0000', i.InvoiceID), 4)) AS InvoiceNo,
       s.SubscriberName, i.DueDate, i.Amount, DATEDIFF(DAY, i.DueDate, @Today) AS DaysOverdue
FROM dbo.invoices AS i
JOIN dbo.subscribers AS s ON s.SubscriberID = i.SubscriberID
WHERE i.PaidDate IS NULL AND DATEDIFF(DAY, i.DueDate, @Today) > 15
ORDER BY DaysOverdue DESC, i.InvoiceID;

SELECT s.SubscriberID, s.SubscriberName, s.Circle
FROM dbo.subscribers AS s
LEFT JOIN dbo.call_records AS cr ON cr.SubscriberID = s.SubscriberID
WHERE cr.CallID IS NULL;

SELECT s.Circle, COUNT(DISTINCT s.SubscriberID) AS Subscribers, SUM(i.Amount) AS Billed,
       CAST(SUM(i.Amount) / COUNT(DISTINCT s.SubscriberID) AS DECIMAL(10,2)) AS ARPU
FROM dbo.subscribers AS s
LEFT JOIN dbo.invoices AS i ON i.SubscriberID = s.SubscriberID
     AND i.InvoiceDate >= '2026-10-01' AND i.InvoiceDate < '2026-11-01'
GROUP BY s.Circle
ORDER BY ARPU DESC;

SELECT p.PlanName, COUNT(*) AS Subscribers,
       CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS SharePct
FROM dbo.subscribers AS s
JOIN dbo.plans AS p ON p.PlanID = s.PlanID
GROUP BY p.PlanName
ORDER BY Subscribers DESC;

SELECT TOP 10 s.SubscriberName, SUM(cr.DataUsedMB) AS DataUsedMB
FROM dbo.subscribers AS s
JOIN dbo.call_records AS cr ON cr.SubscriberID = s.SubscriberID
GROUP BY s.SubscriberName
ORDER BY DataUsedMB DESC;

SELECT CONCAT('INV-', FORMAT(i.InvoiceDate, 'yyyyMM'), '-', RIGHT(CONCAT('0000', i.InvoiceID), 4)) AS InvoiceNo,
       s.SubscriberName, FORMAT(i.DueDate, 'dd MMM yyyy') AS DueOn,
       CASE WHEN i.PaidDate IS NOT NULL THEN 'Paid'
            WHEN i.DueDate >= @Today THEN CONCAT('Due in ', DATEDIFF(DAY, @Today, i.DueDate), ' days')
            ELSE CONCAT('Overdue by ', DATEDIFF(DAY, i.DueDate, @Today), ' days') END AS DueStatus
FROM dbo.invoices AS i
JOIN dbo.subscribers AS s ON s.SubscriberID = i.SubscriberID
WHERE s.SubscriberID IN (5, 9)
ORDER BY s.SubscriberID, i.InvoiceDate;

WITH PerSubscriber AS (
    SELECT s.SubscriberID, SUM(cr.DataUsedMB) AS TotalData
    FROM dbo.subscribers AS s
    LEFT JOIN dbo.call_records AS cr ON cr.SubscriberID = s.SubscriberID
    GROUP BY s.SubscriberID
)
SELECT COUNT(*) AS Subscribers,
       COUNT(TotalData) AS WithData,
       SUM(TotalData) AS TotalMB,
       CAST(AVG(TotalData) AS DECIMAL(10,2)) AS AvgIgnoringNull,
       CAST(AVG(COALESCE(TotalData, 0)) AS DECIMAL(10,2)) AS AvgNullAsZero
FROM PerSubscriber;
