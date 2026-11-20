/*
DAY 9 — INSURANCE PREMIUM PROCESSING
CONSOLIDATED SQL SERVER SCRIPT

Run this single file in SQL Server Management Studio (SSMS).
Sections are ordered: schema/setup → views → procedures/functions → cursor/set-based.
*/


/* ============================================================
   SCHEMA SETUP
   ============================================================ */

IF DB_ID(N'InsurancePremiumDB') IS NULL CREATE DATABASE InsurancePremiumDB;
GO
USE InsurancePremiumDB;
GO
DROP TABLE IF EXISTS dbo.PolicyAudit;
DROP TABLE IF EXISTS dbo.CustomerCommunications;
DROP TABLE IF EXISTS dbo.Claims;
DROP TABLE IF EXISTS dbo.Policies;
DROP TABLE IF EXISTS dbo.InsuranceCustomers;
DROP TABLE IF EXISTS dbo.Agents;
GO
CREATE TABLE dbo.InsuranceCustomers(CustomerID INT IDENTITY PRIMARY KEY,FullName NVARCHAR(120) NOT NULL,Email NVARCHAR(150) NOT NULL,Phone NVARCHAR(30),NationalID NVARCHAR(30));
CREATE TABLE dbo.Agents(AgentID INT IDENTITY PRIMARY KEY,AgentName NVARCHAR(100) NOT NULL);
CREATE TABLE dbo.Policies(PolicyID INT IDENTITY PRIMARY KEY,CustomerID INT NOT NULL REFERENCES dbo.InsuranceCustomers(CustomerID),AgentID INT NOT NULL REFERENCES dbo.Agents(AgentID),PolicyType NVARCHAR(50) NOT NULL,Status VARCHAR(20) NOT NULL CHECK(Status IN('Active','Lapsed','Cancelled')),PremiumAmount DECIMAL(12,2) NOT NULL CHECK(PremiumAmount>=0),RenewalDate DATE NOT NULL,NoClaimYears INT NOT NULL DEFAULT 0,LastRenewedOn DATE NULL);
CREATE TABLE dbo.Claims(ClaimID INT IDENTITY PRIMARY KEY,PolicyID INT NOT NULL REFERENCES dbo.Policies(PolicyID),ClaimStatus VARCHAR(20) NOT NULL CHECK(ClaimStatus IN('Pending','Approved','Rejected')),ClaimAmount DECIMAL(12,2) NOT NULL DEFAULT 0);
CREATE TABLE dbo.PolicyAudit(AuditID INT IDENTITY PRIMARY KEY,PolicyID INT NOT NULL REFERENCES dbo.Policies(PolicyID),ActionName NVARCHAR(50) NOT NULL,OldPremium DECIMAL(12,2),NewPremium DECIMAL(12,2),ActionAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),Details NVARCHAR(250));
CREATE TABLE dbo.CustomerCommunications(CommunicationID INT IDENTITY PRIMARY KEY,CustomerID INT NOT NULL REFERENCES dbo.InsuranceCustomers(CustomerID),Channel VARCHAR(20) NOT NULL,Subject NVARCHAR(150),IsComplaint BIT NOT NULL DEFAULT 0,IsResolved BIT NOT NULL DEFAULT 0,CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME());
INSERT dbo.InsuranceCustomers(FullName,Email,Phone,NationalID) VALUES(N'Ananya Rao',N'ananya@example.com',N'9000000001',N'ID-SECRET-001'),(N'Vikram Nair',N'vikram@example.com',N'9000000002',N'ID-SECRET-002'),(N'Sana Ali',N'sana@example.com',N'9000000003',N'ID-SECRET-003');
INSERT dbo.Agents(AgentName) VALUES(N'Priya Menon'),(N'Arjun Das');
INSERT dbo.Policies(CustomerID,AgentID,PolicyType,Status,PremiumAmount,RenewalDate,NoClaimYears) VALUES
(1,1,N'Health','Active',12000,DATEADD(DAY,15,CONVERT(date,GETDATE())),3),
(2,1,N'Vehicle','Active',8500,DATEADD(DAY,30,CONVERT(date,GETDATE())),1),
(3,2,N'Health','Lapsed',15000,DATEADD(DAY,-10,CONVERT(date,GETDATE())),0);
INSERT dbo.Claims(PolicyID,ClaimStatus,ClaimAmount) VALUES(1,'Rejected',2000),(2,'Pending',4000);
INSERT dbo.CustomerCommunications(CustomerID,Channel,Subject,IsComplaint,IsResolved) VALUES
(1,'Email',N'Claim status complaint',1,0),(2,'Phone',N'Policy query',0,0),(3,'Email',N'Renewal complaint',1,1);
GO



/* ============================================================
   VIEWS
   ============================================================ */

USE InsurancePremiumDB;
GO
CREATE OR ALTER VIEW dbo.vw_policy_due AS
SELECT p.PolicyID,c.CustomerID,c.FullName,c.Email,c.Phone,p.PolicyType,p.Status,
       p.PremiumAmount,p.RenewalDate,p.AgentID
FROM dbo.Policies p JOIN dbo.InsuranceCustomers c ON c.CustomerID=p.CustomerID
WHERE p.Status='Active'
AND p.RenewalDate>=CONVERT(date,GETDATE())
AND p.RenewalDate<DATEADD(DAY,31,CONVERT(date,GETDATE()));
GO
SELECT * FROM dbo.vw_policy_due;
-- NationalID is intentionally excluded from the view.
GO



/* ============================================================
   STORED PROCEDURES AND FUNCTIONS
   ============================================================ */

USE InsurancePremiumDB;
GO
CREATE OR ALTER FUNCTION dbo.fn_PremiumWithNoClaimDiscount
(@BasePremium DECIMAL(12,2),@NoClaimYears INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
 DECLARE @Discount DECIMAL(5,4)=CASE WHEN @NoClaimYears>=5 THEN 0.20 WHEN @NoClaimYears>=3 THEN 0.15 WHEN @NoClaimYears>=1 THEN 0.05 ELSE 0 END;
 RETURN ROUND(@BasePremium*(1-@Discount),2);
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_AgentRenewalQuotes(@AgentID INT)
RETURNS TABLE AS RETURN
(
 SELECT p.PolicyID,p.CustomerID,c.FullName,p.PolicyType,p.RenewalDate,p.PremiumAmount AS CurrentPremium,
        dbo.fn_PremiumWithNoClaimDiscount(p.PremiumAmount,p.NoClaimYears) AS QuotedPremium
 FROM dbo.Policies p JOIN dbo.InsuranceCustomers c ON c.CustomerID=p.CustomerID
 WHERE p.AgentID=@AgentID AND p.Status='Active'
);
GO
CREATE OR ALTER PROCEDURE dbo.usp_RenewPolicy @PolicyID INT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @OldPremium DECIMAL(12,2),@NewPremium DECIMAL(12,2),@NoClaimYears INT,@Status VARCHAR(20);
 BEGIN TRY
  BEGIN TRANSACTION;
  SELECT @OldPremium=PremiumAmount,@NoClaimYears=NoClaimYears,@Status=Status
  FROM dbo.Policies WITH(UPDLOCK,HOLDLOCK) WHERE PolicyID=@PolicyID;
  IF @OldPremium IS NULL THROW 52001,'Policy not found.',1;
  IF @Status<>'Active' THROW 52002,'Only active policies can be renewed.',1;
  IF EXISTS(SELECT 1 FROM dbo.Claims WHERE PolicyID=@PolicyID AND ClaimStatus='Pending')
    THROW 52003,'Policy has a pending claim and cannot be renewed.',1;
  SET @NewPremium=dbo.fn_PremiumWithNoClaimDiscount(@OldPremium,@NoClaimYears);
  UPDATE dbo.Policies SET PremiumAmount=@NewPremium,RenewalDate=DATEADD(YEAR,1,RenewalDate),LastRenewedOn=CONVERT(date,GETDATE())
  WHERE PolicyID=@PolicyID;
  INSERT dbo.PolicyAudit(PolicyID,ActionName,OldPremium,NewPremium,Details)
  VALUES(@PolicyID,N'RENEWAL',@OldPremium,@NewPremium,N'Premium recalculated using no-claim discount.');
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH
END;
GO
-- Example:
-- EXEC dbo.usp_RenewPolicy @PolicyID=1;
-- SELECT * FROM dbo.fn_AgentRenewalQuotes(1);
GO



/* ============================================================
   CURSOR AND SET-BASED ALTERNATIVE
   ============================================================ */

USE InsurancePremiumDB;
GO
-- Cursor implementation: log each policy that has passed its renewal date.
DECLARE @PolicyID INT,@OldStatus VARCHAR(20);
DECLARE lapse_cursor CURSOR LOCAL FAST_FORWARD FOR
 SELECT PolicyID,Status FROM dbo.Policies
 WHERE Status='Active' AND RenewalDate<CONVERT(date,GETDATE());
OPEN lapse_cursor;
FETCH NEXT FROM lapse_cursor INTO @PolicyID,@OldStatus;
WHILE @@FETCH_STATUS=0
BEGIN
 BEGIN TRANSACTION;
 UPDATE dbo.Policies SET Status='Lapsed' WHERE PolicyID=@PolicyID AND Status='Active';
 IF @@ROWCOUNT=1
  INSERT dbo.PolicyAudit(PolicyID,ActionName,Details)
  VALUES(@PolicyID,N'LAPSE',N'Policy marked Lapsed by daily lapse process.');
 COMMIT;
 FETCH NEXT FROM lapse_cursor INTO @PolicyID,@OldStatus;
END;
CLOSE lapse_cursor; DEALLOCATE lapse_cursor;
GO
-- Set-based rewrite with equivalent audit logging.
BEGIN TRANSACTION;
DECLARE @Changed TABLE(PolicyID INT PRIMARY KEY);
UPDATE dbo.Policies
SET Status='Lapsed'
OUTPUT inserted.PolicyID INTO @Changed(PolicyID)
WHERE Status='Active' AND RenewalDate<CONVERT(date,GETDATE());
INSERT dbo.PolicyAudit(PolicyID,ActionName,Details)
SELECT PolicyID,N'LAPSE',N'Policy marked Lapsed by set-based lapse process.' FROM @Changed;
COMMIT;
GO
SELECT * FROM dbo.PolicyAudit ORDER BY AuditID;

