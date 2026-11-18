IF DB_ID(N'BankLoanPortfolio') IS NULL
    CREATE DATABASE BankLoanPortfolio;
GO

USE BankLoanPortfolio;
GO

IF OBJECT_ID(N'dbo.Guarantors', N'U') IS NOT NULL DROP TABLE dbo.Guarantors;
IF OBJECT_ID(N'dbo.Repayments', N'U') IS NOT NULL DROP TABLE dbo.Repayments;
IF OBJECT_ID(N'dbo.Loans', N'U') IS NOT NULL DROP TABLE dbo.Loans;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID(N'dbo.Branches', N'U') IS NOT NULL DROP TABLE dbo.Branches;
GO

CREATE TABLE dbo.Branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20)
);

CREATE TABLE dbo.Loans (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    outstanding_balance DECIMAL(12,2) NOT NULL,
    monthly_instalment DECIMAL(10,2) NOT NULL,
    loan_start_date DATE NOT NULL,
    next_due_date DATE NOT NULL,
    loan_status VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Loans_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    CONSTRAINT FK_Loans_Branch FOREIGN KEY (branch_id) REFERENCES dbo.Branches(branch_id)
);

CREATE TABLE dbo.Repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    repayment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Repayments_Loan FOREIGN KEY (loan_id) REFERENCES dbo.Loans(loan_id)
);

CREATE TABLE dbo.Guarantors (
    guarantor_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    guarantor_customer_id INT NOT NULL,
    guarantee_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Guarantors_Loan FOREIGN KEY (loan_id) REFERENCES dbo.Loans(loan_id),
    CONSTRAINT FK_Guarantors_Customer FOREIGN KEY (guarantor_customer_id) REFERENCES dbo.Customers(customer_id)
);
GO

INSERT INTO dbo.Branches (branch_id, branch_name, city) VALUES
(1, 'Chennai Main', 'Chennai'),
(2, 'Bengaluru Central', 'Bengaluru'),
(3, 'Hyderabad City', 'Hyderabad'),
(4, 'Mumbai Fort', 'Mumbai'),
(5, 'Kochi Marine', 'Kochi');

INSERT INTO dbo.Customers (customer_id, customer_name, email, phone) VALUES
(101, 'Arun Kumar', 'arun@example.com', '9000000101'),
(102, 'Priya Nair', 'priya@example.com', '9000000102'),
(103, 'Rahul Shah', 'rahul@example.com', '9000000103'),
(104, 'Meena Das', 'meena@example.com', '9000000104'),
(105, 'Vikram Rao', 'vikram@example.com', '9000000105'),
(106, 'Sara Joseph', 'sara@example.com', '9000000106');

INSERT INTO dbo.Loans
(loan_id, customer_id, branch_id, loan_type, principal_amount, outstanding_balance, monthly_instalment, loan_start_date, next_due_date, loan_status)
VALUES
(5001, 101, 1, 'Home Loan', 3000000, 2450000, 25000, '2023-01-15', '2026-06-05', 'Active'),
(5002, 102, 1, 'Personal Loan', 500000, 280000, 18000, '2025-02-10', '2026-11-05', 'Active'),
(5003, 103, 2, 'Vehicle Loan', 900000, 510000, 22000, '2024-06-01', '2026-10-05', 'Active'),
(5004, 101, 2, 'Business Loan', 1500000, 1100000, 30000, '2024-03-20', '2026-09-05', 'Active'),
(5005, 104, 3, 'Education Loan', 800000, 600000, 12000, '2025-01-10', '2026-11-05', 'Active'),
(5006, 105, 3, 'Home Loan', 2500000, 2100000, 24000, '2022-08-15', '2026-07-05', 'Active'),
(5007, 106, 4, 'Personal Loan', 350000, 150000, 15000, '2025-05-12', '2026-11-05', 'Active'),
(5008, 103, 1, 'Gold Loan', 200000, 80000, 10000, '2026-01-01', '2026-11-05', 'Active');

INSERT INTO dbo.Repayments (repayment_id, loan_id, repayment_date, amount_paid, payment_mode) VALUES
(1, 5001, '2026-03-05', 25000, 'Auto Debit'),
(2, 5001, '2026-04-05', 25000, 'Auto Debit'),
(3, 5001, '2026-05-05', 25000, 'Auto Debit'),
(4, 5002, '2026-10-05', 18000, 'UPI'),
(5, 5002, '2026-11-05', 18000, 'UPI'),
(6, 5003, '2026-10-05', 22000, 'Bank Transfer'),
(7, 5004, '2026-06-05', 30000, 'Auto Debit'),
(8, 5004, '2026-07-05', 30000, 'Auto Debit'),
(9, 5005, '2026-11-05', 12000, 'UPI'),
(10, 5006, '2026-07-05', 24000, 'Auto Debit'),
(11, 5007, '2026-11-05', 15000, 'UPI'),
(12, 5008, '2026-10-05', 10000, 'Cash');

INSERT INTO dbo.Guarantors (guarantor_id, loan_id, guarantor_customer_id, guarantee_amount) VALUES
(1, 5001, 102, 500000),
(2, 5002, 103, 100000),
(3, 5003, 101, 200000),
(4, 5005, 106, 150000),
(5, 5006, 104, 300000);
GO

SELECT l.loan_id, c.customer_name, b.branch_name,
       DATEDIFF(MONTH, l.next_due_date, CAST(GETDATE() AS DATE)) AS months_overdue,
       l.monthly_instalment
FROM dbo.Loans l
INNER JOIN dbo.Customers c ON c.customer_id = l.customer_id
INNER JOIN dbo.Branches b ON b.branch_id = l.branch_id
WHERE l.loan_status = 'Active'
  AND l.next_due_date < CAST(GETDATE() AS DATE)
  AND DATEDIFF(MONTH, l.next_due_date, CAST(GETDATE() AS DATE)) > 3;

SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT l.branch_id) AS branch_count
FROM dbo.Customers c
INNER JOIN dbo.Loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT l.branch_id) > 1;

SELECT DISTINCT g.guarantor_customer_id, guarantor.customer_name
FROM dbo.Guarantors g
INNER JOIN dbo.Customers guarantor ON guarantor.customer_id = g.guarantor_customer_id
INNER JOIN dbo.Loans borrower_loan ON borrower_loan.customer_id = g.guarantor_customer_id;

SELECT b.branch_id, b.branch_name
FROM dbo.Branches b
LEFT JOIN dbo.Loans l ON l.branch_id = b.branch_id
WHERE l.loan_id IS NULL;

SELECT c.customer_id, c.customer_name, SUM(l.outstanding_balance) AS total_loan_exposure
FROM dbo.Customers c
INNER JOIN dbo.Loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

SELECT l.loan_id, c.customer_name, l.principal_amount, l.outstanding_balance,
       COALESCE(SUM(r.amount_paid), 0) AS total_repaid
FROM dbo.Loans l
INNER JOIN dbo.Customers c ON c.customer_id = l.customer_id
LEFT JOIN dbo.Repayments r ON r.loan_id = l.loan_id
GROUP BY l.loan_id, c.customer_name, l.principal_amount, l.outstanding_balance;

SELECT l.loan_id, c.customer_name, b.branch_name
FROM dbo.Loans l
INNER JOIN dbo.Customers c ON c.customer_id = l.customer_id
INNER JOIN dbo.Branches b ON b.branch_id = l.branch_id
LEFT JOIN dbo.Repayments r ON r.loan_id = l.loan_id
WHERE r.repayment_id IS NULL;

SELECT b.branch_name, COUNT(l.loan_id) AS loan_count,
       COALESCE(SUM(l.outstanding_balance), 0) AS total_outstanding
FROM dbo.Branches b
LEFT JOIN dbo.Loans l ON l.branch_id = b.branch_id
GROUP BY b.branch_name;

SELECT l.loan_id, c.customer_name, g.guarantee_amount,
       guarantor.customer_name AS guarantor_name
FROM dbo.Loans l
INNER JOIN dbo.Customers c ON c.customer_id = l.customer_id
LEFT JOIN dbo.Guarantors g ON g.loan_id = l.loan_id
LEFT JOIN dbo.Customers guarantor ON guarantor.customer_id = g.guarantor_customer_id;

SELECT b.branch_name, l.loan_id, l.loan_type, l.outstanding_balance
FROM dbo.Branches b
INNER JOIN dbo.Loans l ON l.branch_id = b.branch_id
WHERE l.outstanding_balance > (
    SELECT AVG(l2.outstanding_balance)
    FROM dbo.Loans l2
    WHERE l2.branch_id = l.branch_id
);

SELECT c.customer_id, c.customer_name,
       SUM(l.outstanding_balance) AS total_loan_exposure
FROM dbo.Customers c
INNER JOIN dbo.Loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(l.outstanding_balance) > (
    SELECT AVG(branch_exposure)
    FROM (
        SELECT branch_id, SUM(outstanding_balance) AS branch_exposure
        FROM dbo.Loans
        GROUP BY branch_id
    ) AS branch_totals
);

SELECT c.customer_id, c.customer_name
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1
    FROM dbo.Loans l
    WHERE l.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Loans l
    INNER JOIN dbo.Repayments r ON r.loan_id = l.loan_id
    WHERE l.customer_id = c.customer_id
      AND r.repayment_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
);

SELECT b.branch_id, b.branch_name
FROM dbo.Branches b
WHERE (
    SELECT MAX(l.outstanding_balance)
    FROM dbo.Loans l
    WHERE l.branch_id = b.branch_id
) > (
    SELECT AVG(branch_maximum)
    FROM (
        SELECT MAX(l2.outstanding_balance) AS branch_maximum
        FROM dbo.Loans l2
        GROUP BY l2.branch_id
    ) AS branch_maximums
);

SELECT c.customer_name, l.loan_id, l.outstanding_balance
FROM dbo.Customers c
INNER JOIN dbo.Loans l ON l.customer_id = c.customer_id
WHERE l.outstanding_balance > (
    SELECT AVG(l2.outstanding_balance)
    FROM dbo.Loans l2
    WHERE l2.branch_id = l.branch_id
);

SELECT b.branch_name, l.loan_id, l.outstanding_balance
FROM dbo.Branches b
INNER JOIN (
    SELECT branch_id, MAX(outstanding_balance) AS highest_loan
    FROM dbo.Loans
    GROUP BY branch_id
) AS branch_highest ON branch_highest.branch_id = b.branch_id
INNER JOIN dbo.Loans l
    ON l.branch_id = branch_highest.branch_id
   AND l.outstanding_balance = branch_highest.highest_loan;
