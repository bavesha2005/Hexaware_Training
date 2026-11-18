CREATE DATABASE InsuranceDB;
GO
USE InsuranceDB;
GO

CREATE TABLE dbo.customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(80) NOT NULL,
    DateOfBirth  DATE NOT NULL
);

CREATE TABLE dbo.agents (
    AgentID   INT IDENTITY(1,1) PRIMARY KEY,
    AgentName NVARCHAR(80) NOT NULL
);

CREATE TABLE dbo.products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(80) NOT NULL
);

CREATE TABLE dbo.policies (
    PolicyID     INT IDENTITY(1,1) PRIMARY KEY,
    PolicyNumber VARCHAR(20) NOT NULL UNIQUE,
    CustomerID   INT NOT NULL REFERENCES dbo.customers(CustomerID),
    ProductID    INT NOT NULL REFERENCES dbo.products(ProductID),
    AgentID      INT NOT NULL REFERENCES dbo.agents(AgentID),
    StartDate    DATE NOT NULL,
    EndDate      DATE NOT NULL,
    Status       VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.premiums (
    PremiumID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID  INT NOT NULL REFERENCES dbo.policies(PolicyID),
    Amount    DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.claims (
    ClaimID     INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID    INT NOT NULL REFERENCES dbo.policies(PolicyID),
    ClaimAmount DECIMAL(10,2) NOT NULL,
    ClaimDate   DATE NOT NULL,
    Status      VARCHAR(10) NOT NULL,
    SettledDate DATE NULL
);
GO

INSERT INTO dbo.customers (CustomerName, DateOfBirth) VALUES
(N'Arun', '1985-04-12'), (N'Divya', '1998-09-30'), (N'Karthik', '1975-01-20'), (N'Meena', '1990-07-07'),
(N'Rahul', '2001-11-02'), (N'Sneha', '1962-03-15'), (N'Vikram', '1980-12-25'), (N'Priya', '1995-06-18');

INSERT INTO dbo.agents (AgentName) VALUES
(N'Anand'), (N'Bhavna'), (N'Chandran'), (N'Deepa'), (N'Eswar'), (N'Farida');

INSERT INTO dbo.products (ProductName) VALUES
(N'Motor Insurance'), (N'Health Insurance'), (N'Home Insurance'), (N'Travel Insurance');

INSERT INTO dbo.policies (PolicyNumber, CustomerID, ProductID, AgentID, StartDate, EndDate, Status) VALUES
('MOT-2025-481209', 1, 1, 1, '2025-12-01', '2026-11-30', 'Active'),
('HLT-2026-520346', 1, 2, 2, '2026-01-28', '2027-01-27', 'Active'),
('MOT-2026-530781', 2, 1, 1, '2026-01-15', '2027-01-14', 'Active'),
('HOM-2024-410592', 3, 3, 3, '2024-12-20', '2025-12-19', 'Expired'),
('HLT-2026-540167', 3, 2, 2, '2026-03-05', '2027-03-04', 'Active'),
('TRV-2026-560934', 4, 4, 4, '2026-11-10', '2026-12-09', 'Active'),
('MOT-2025-490825', 4, 1, 1, '2025-06-01', '2026-05-31', 'Expired'),
('HOM-2026-550278', 5, 3, 3, '2026-03-22', '2027-03-21', 'Active'),
('HLT-2025-495613', 6, 2, 5, '2025-11-25', '2026-11-24', 'Active'),
('MOT-2026-545890', 7, 1, 5, '2026-05-02', '2027-05-01', 'Active'),
('HLT-2026-570421', 7, 2, 2, '2026-07-14', '2027-07-13', 'Active'),
('TRV-2026-559106', 8, 4, 6, '2026-10-01', '2026-12-31', 'Active');

INSERT INTO dbo.premiums (PolicyID, Amount) VALUES
(1, 12000), (2, 15000), (3, 9000), (4, 6000), (5, 14000), (6, 1500),
(7, 11000), (8, 8000), (9, 16000), (10, 10000), (11, 15000), (12, 2000);

INSERT INTO dbo.claims (PolicyID, ClaimAmount, ClaimDate, Status, SettledDate) VALUES
(1, 4000, '2026-03-10', 'Settled', '2026-03-25'),
(2, 6000, '2026-04-02', 'Settled', '2026-04-30'),
(4, 3000, '2025-06-15', 'Settled', '2025-07-05'),
(5, 2500, '2026-06-12', 'Open', NULL),
(7, 3500, '2026-01-20', 'Rejected', NULL),
(9, 9000, '2026-08-05', 'Settled', '2026-09-04'),
(10, 1800, '2026-09-15', 'Open', NULL),
(3, 1400, '2026-05-20', 'Settled', '2026-06-09');
GO

DECLARE @Today DATE = '2026-11-18';

SELECT p.PolicyNumber, c.CustomerName, p.EndDate, DATEDIFF(DAY, @Today, p.EndDate) AS DaysLeft
FROM dbo.policies AS p
JOIN dbo.customers AS c ON c.CustomerID = p.CustomerID
WHERE p.Status = 'Active' AND p.EndDate BETWEEN @Today AND DATEADD(DAY, 30, @Today)
ORDER BY p.EndDate;

SELECT pr.ProductName, SUM(pm.Amount) AS PremiumCollected
FROM dbo.premiums AS pm
JOIN dbo.policies AS p ON p.PolicyID = pm.PolicyID
JOIN dbo.products AS pr ON pr.ProductID = p.ProductID
GROUP BY pr.ProductName
ORDER BY PremiumCollected DESC;

SELECT c.CustomerName, COUNT(*) AS ActivePolicies
FROM dbo.customers AS c
JOIN dbo.policies AS p ON p.CustomerID = c.CustomerID
WHERE p.Status = 'Active'
GROUP BY c.CustomerName
HAVING COUNT(*) > 1;

WITH Prem AS (
    SELECT p.ProductID, SUM(pm.Amount) AS Premium
    FROM dbo.premiums AS pm JOIN dbo.policies AS p ON p.PolicyID = pm.PolicyID
    GROUP BY p.ProductID
), Clm AS (
    SELECT p.ProductID, SUM(cl.ClaimAmount) AS Claims
    FROM dbo.claims AS cl JOIN dbo.policies AS p ON p.PolicyID = cl.PolicyID
    GROUP BY p.ProductID
)
SELECT pr.ProductName, Prem.Premium, ISNULL(Clm.Claims, 0) AS Claims,
       CAST(100.0 * ISNULL(Clm.Claims, 0) / Prem.Premium AS DECIMAL(5,2)) AS ClaimRatioPct
FROM dbo.products AS pr
JOIN Prem ON Prem.ProductID = pr.ProductID
LEFT JOIN Clm ON Clm.ProductID = pr.ProductID
ORDER BY pr.ProductID;

SELECT p.PolicyID, p.PolicyNumber, c.CustomerName
FROM dbo.policies AS p
JOIN dbo.customers AS c ON c.CustomerID = p.CustomerID
LEFT JOIN dbo.claims AS cl ON cl.PolicyID = p.PolicyID
WHERE cl.ClaimID IS NULL;

WITH Aged AS (
    SELECT DATEDIFF(YEAR, c.DateOfBirth, @Today) AS Age, pm.Amount
    FROM dbo.customers AS c
    JOIN dbo.policies AS p ON p.CustomerID = c.CustomerID
    JOIN dbo.premiums AS pm ON pm.PolicyID = p.PolicyID
), Banded AS (
    SELECT CASE WHEN Age < 30 THEN '18-29' WHEN Age < 45 THEN '30-44' WHEN Age < 60 THEN '45-59' ELSE '60+' END AS AgeBand, Amount
    FROM Aged
)
SELECT AgeBand, COUNT(*) AS Policies, CAST(AVG(Amount) AS DECIMAL(10,2)) AS AvgPremium
FROM Banded
GROUP BY AgeBand
ORDER BY AgeBand;

SELECT FORMAT(StartDate, 'yyyy-MM') AS StartMonth, COUNT(*) AS NewPolicies
FROM dbo.policies
WHERE StartDate >= '2026-01-01'
GROUP BY FORMAT(StartDate, 'yyyy-MM')
ORDER BY StartMonth;

SELECT TOP 5 a.AgentName, SUM(pm.Amount) AS TotalPremium
FROM dbo.agents AS a
JOIN dbo.policies AS p ON p.AgentID = a.AgentID
JOIN dbo.premiums AS pm ON pm.PolicyID = p.PolicyID
GROUP BY a.AgentName
ORDER BY TotalPremium DESC, a.AgentName;

SELECT CONCAT(LEFT(PolicyNumber, 4), REPLICATE('*', LEN(PolicyNumber) - 8), RIGHT(PolicyNumber, 4)) AS MaskedPolicyNo,
       DATEDIFF(MONTH, StartDate, @Today) AS AgeInMonths,
       CASE WHEN DATEDIFF(MONTH, StartDate, @Today) < 3 THEN 'New'
            WHEN DATEDIFF(MONTH, StartDate, @Today) < 12 THEN 'Growing'
            ELSE 'Mature' END AS PolicyAgeBand
FROM dbo.policies
ORDER BY PolicyID;
