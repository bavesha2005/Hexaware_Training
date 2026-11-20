/*
DAY 9 — TELECOM LOW-BALANCE FOLLOW-UP
CONSOLIDATED SQL SERVER SCRIPT

Run this single file in SQL Server Management Studio (SSMS).
Sections are ordered: schema/setup → views → procedures/functions → cursor/set-based.
*/


/* ============================================================
   SCHEMA SETUP
   ============================================================ */

IF DB_ID(N'TelecomPrepaidDB') IS NULL CREATE DATABASE TelecomPrepaidDB;
GO
USE TelecomPrepaidDB;
GO
DROP TABLE IF EXISTS dbo.NotificationLog;
DROP TABLE IF EXISTS dbo.RechargeHistory;
DROP TABLE IF EXISTS dbo.Subscribers;
DROP TABLE IF EXISTS dbo.MobilePlans;
GO
CREATE TABLE dbo.MobilePlans(PlanID INT IDENTITY PRIMARY KEY,PlanName NVARCHAR(80) NOT NULL,RechargeAmount DECIMAL(10,2) NOT NULL CHECK(RechargeAmount>0),ValidityDays INT NOT NULL CHECK(ValidityDays>0),IsActive BIT NOT NULL DEFAULT 1);
CREATE TABLE dbo.Subscribers(SubscriberID INT IDENTITY PRIMARY KEY,FullName NVARCHAR(100) NOT NULL,MobileNumber VARCHAR(20) NOT NULL UNIQUE,ServiceType VARCHAR(10) NOT NULL CHECK(ServiceType IN('Prepaid','Postpaid')),Balance DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK(Balance>=0),PlanID INT NULL REFERENCES dbo.MobilePlans(PlanID),ValidityEndDate DATE NULL,IsActive BIT NOT NULL DEFAULT 1);
CREATE TABLE dbo.RechargeHistory(RechargeID INT IDENTITY PRIMARY KEY,SubscriberID INT NOT NULL REFERENCES dbo.Subscribers(SubscriberID),PlanID INT NOT NULL REFERENCES dbo.MobilePlans(PlanID),Amount DECIMAL(10,2) NOT NULL CHECK(Amount>0),RechargeDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),BalanceAfter DECIMAL(12,2) NOT NULL);
CREATE TABLE dbo.NotificationLog(NotificationID INT IDENTITY PRIMARY KEY,SubscriberID INT NOT NULL REFERENCES dbo.Subscribers(SubscriberID),MessageText NVARCHAR(250) NOT NULL,CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),IsRead BIT NOT NULL DEFAULT 0);
INSERT dbo.MobilePlans(PlanName,RechargeAmount,ValidityDays) VALUES(N'Basic 28 Days',199,28),(N'Value 56 Days',399,56),(N'Premium 84 Days',599,84);
INSERT dbo.Subscribers(FullName,MobileNumber,ServiceType,Balance,PlanID,ValidityEndDate) VALUES
(N'Kavya Iyer','9000000101','Prepaid',24,1,DATEADD(DAY,5,CONVERT(date,GETDATE()))),
(N'Rahul Bose','9000000102','Prepaid',120,2,DATEADD(DAY,20,CONVERT(date,GETDATE()))),
(N'Imran Khan','9000000103','Prepaid',42,1,DATEADD(DAY,-2,CONVERT(date,GETDATE()))),
(N'Neha Paul','9000000104','Postpaid',15,3,DATEADD(DAY,30,CONVERT(date,GETDATE())));
INSERT dbo.RechargeHistory(SubscriberID,PlanID,Amount,BalanceAfter,RechargeDate) VALUES
(1,1,199,223,DATEADD(DAY,-30,SYSDATETIME())),(1,1,199,422,DATEADD(DAY,-10,SYSDATETIME())),
(2,2,399,519,DATEADD(DAY,-15,SYSDATETIME())),(3,1,199,241,DATEADD(DAY,-35,SYSDATETIME()));
INSERT dbo.NotificationLog(SubscriberID,MessageText,IsRead) VALUES(1,N'Your prepaid balance is low.',0),(2,N'Welcome back.',1);
GO



/* ============================================================
   VIEWS
   ============================================================ */

USE TelecomPrepaidDB;
GO
CREATE OR ALTER VIEW dbo.vw_prepaid_subscribers AS
SELECT SubscriberID,FullName,MobileNumber,Balance,PlanID,ValidityEndDate,IsActive
FROM dbo.Subscribers WHERE ServiceType='Prepaid' WITH CHECK OPTION;
GO
CREATE OR ALTER VIEW dbo.vw_recharge_summary AS
SELECT s.SubscriberID,s.FullName,COUNT(r.RechargeID) AS RechargeCount,
       COALESCE(SUM(r.Amount),0) AS TotalRecharged,
       MAX(r.RechargeDate) AS LastRechargeAt
FROM dbo.Subscribers s LEFT JOIN dbo.RechargeHistory r ON r.SubscriberID=s.SubscriberID
WHERE s.ServiceType='Prepaid'
GROUP BY s.SubscriberID,s.FullName;
GO
SELECT * FROM dbo.vw_prepaid_subscribers;
SELECT * FROM dbo.vw_recharge_summary;
-- Postpaid rows are excluded by the view predicate; WITH CHECK OPTION prevents
-- inserting/updating a row through this view so it becomes Postpaid.
GO



/* ============================================================
   STORED PROCEDURES AND FUNCTIONS
   ============================================================ */

USE TelecomPrepaidDB;
GO
CREATE OR ALTER FUNCTION dbo.fn_ValidityDaysLeft(@SubscriberID INT)
RETURNS INT
AS
BEGIN
 DECLARE @Days INT;
 SELECT @Days=DATEDIFF(DAY,CONVERT(date,GETDATE()),ValidityEndDate)
 FROM dbo.Subscribers WHERE SubscriberID=@SubscriberID AND ServiceType='Prepaid';
 RETURN @Days;
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_LastFiveRecharges(@SubscriberID INT)
RETURNS TABLE AS RETURN
(
 SELECT TOP(5) RechargeID,SubscriberID,PlanID,Amount,RechargeDate,BalanceAfter
 FROM dbo.RechargeHistory WHERE SubscriberID=@SubscriberID
 ORDER BY RechargeDate DESC,RechargeID DESC
);
GO
CREATE OR ALTER PROCEDURE dbo.usp_Recharge
 @SubscriberID INT,@PlanID INT,@Amount DECIMAL(10,2),@NewBalance DECIMAL(12,2) OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @Validity INT,@PlanAmount DECIMAL(10,2);
 BEGIN TRY
  IF @Amount<=0 THROW 53001,'Recharge amount must be positive.',1;
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.Subscribers WITH(UPDLOCK,HOLDLOCK) WHERE SubscriberID=@SubscriberID AND ServiceType='Prepaid' AND IsActive=1)
    THROW 53002,'Active prepaid subscriber not found.',1;
  SELECT @Validity=ValidityDays,@PlanAmount=RechargeAmount
  FROM dbo.MobilePlans WHERE PlanID=@PlanID AND IsActive=1;
  IF @Validity IS NULL THROW 53003,'Selected plan is invalid or inactive.',1;
  IF @Amount<@PlanAmount THROW 53004,'Recharge amount is below the selected plan price.',1;
  UPDATE dbo.Subscribers SET Balance=Balance+@Amount,PlanID=@PlanID,
       ValidityEndDate=CASE WHEN ValidityEndDate>CONVERT(date,GETDATE()) THEN DATEADD(DAY,@Validity,ValidityEndDate) ELSE DATEADD(DAY,@Validity,CONVERT(date,GETDATE())) END
  WHERE SubscriberID=@SubscriberID;
  SELECT @NewBalance=Balance FROM dbo.Subscribers WHERE SubscriberID=@SubscriberID;
  INSERT dbo.RechargeHistory(SubscriberID,PlanID,Amount,BalanceAfter)
  VALUES(@SubscriberID,@PlanID,@Amount,@NewBalance);
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @NewBalance=NULL; THROW;
 END CATCH
END;
GO
-- Example:
-- DECLARE @Balance DECIMAL(12,2);
-- EXEC dbo.usp_Recharge 1,1,199,@Balance OUTPUT;
-- SELECT @Balance AS NewBalance;
-- SELECT dbo.fn_ValidityDaysLeft(1) AS ValidityDaysLeft;
-- SELECT * FROM dbo.fn_LastFiveRecharges(1);
GO



/* ============================================================
   CURSOR AND SET-BASED ALTERNATIVE
   ============================================================ */

USE TelecomPrepaidDB;
GO
-- Cursor approach: add one unread notification for each active prepaid subscriber below 50.
DECLARE @SubscriberID INT,@Balance DECIMAL(12,2);
DECLARE low_balance_cursor CURSOR LOCAL FAST_FORWARD FOR
 SELECT SubscriberID,Balance FROM dbo.Subscribers
 WHERE ServiceType='Prepaid' AND IsActive=1 AND Balance<50;
OPEN low_balance_cursor;
FETCH NEXT FROM low_balance_cursor INTO @SubscriberID,@Balance;
WHILE @@FETCH_STATUS=0
BEGIN
 INSERT dbo.NotificationLog(SubscriberID,MessageText)
 VALUES(@SubscriberID,CONCAT(N'Low balance alert. Current balance: ',FORMAT(@Balance,'N2')));
 FETCH NEXT FROM low_balance_cursor INTO @SubscriberID,@Balance;
END;
CLOSE low_balance_cursor; DEALLOCATE low_balance_cursor;
GO
-- Set-based equivalent. NOT EXISTS avoids duplicate unread alerts when rerun.
INSERT dbo.NotificationLog(SubscriberID,MessageText)
SELECT s.SubscriberID,CONCAT(N'Low balance alert. Current balance: ',FORMAT(s.Balance,'N2'))
FROM dbo.Subscribers s
WHERE s.ServiceType='Prepaid' AND s.IsActive=1 AND s.Balance<50
AND NOT EXISTS(SELECT 1 FROM dbo.NotificationLog n
               WHERE n.SubscriberID=s.SubscriberID AND n.IsRead=0
                 AND n.MessageText LIKE N'Low balance alert.%');
GO
SELECT * FROM dbo.NotificationLog ORDER BY NotificationID;
-- For a fair timing comparison, reset/reseed equivalent eligible rows before each run,
-- execute each approach several times, and compare SET STATISTICS TIME ON output.
SET STATISTICS TIME ON;
GO

