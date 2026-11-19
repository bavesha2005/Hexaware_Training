CREATE DATABASE BankFundsDB;

USE BankFundsDB;

CREATE TABLE dbo.BankAccounts
(
    AccountID INT NOT NULL PRIMARY KEY,
    AccountHolder VARCHAR(80) NOT NULL,
    Balance DECIMAL(18,2) NOT NULL CHECK (Balance >= 0),
    AccountStatus VARCHAR(20) NOT NULL
        CHECK (AccountStatus IN ('ACTIVE', 'BLOCKED'))
);

CREATE TABLE dbo.BankTransactions
(
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    FromAccountID INT NOT NULL,
    ToAccountID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    TransactionType VARCHAR(20) NOT NULL,
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

INSERT INTO dbo.BankAccounts (AccountID, AccountHolder, Balance, AccountStatus)
VALUES
(101, 'Asha', 10000.00, 'ACTIVE'),
(102, 'Ravi', 5000.00, 'ACTIVE'),
(103, 'Blocked Account', 2000.00, 'BLOCKED');
GO

/* 1. Successful funds transfer with validation and TRY...CATCH. */
DECLARE @FromAccountID INT = 101;
DECLARE @ToAccountID INT = 102;
DECLARE @Amount DECIMAL(18,2) = 1500.00;
DECLARE @FromStatus VARCHAR(20);
DECLARE @ToStatus VARCHAR(20);
DECLARE @Balance DECIMAL(18,2);

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @FromStatus = AccountStatus, @Balance = Balance
    FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID = @FromAccountID;

    IF @FromStatus IS NULL
        THROW 50001, 'Source account does not exist.', 1;

    SELECT @ToStatus = AccountStatus
    FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID = @ToAccountID;

    IF @ToStatus IS NULL
        THROW 50002, 'Destination account does not exist.', 1;

    IF @FromStatus <> 'ACTIVE' OR @ToStatus <> 'ACTIVE'
        THROW 50003, 'Both accounts must be active.', 1;

    IF @Balance < @Amount
        THROW 50004, 'Insufficient funds.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccountID;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccountID;

    INSERT INTO dbo.BankTransactions
        (FromAccountID, ToAccountID, Amount, TransactionType)
    VALUES
        (@FromAccountID, @ToAccountID, @Amount, 'TRANSFER');

    COMMIT TRANSACTION;
    PRINT 'Successful transfer committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT('Transfer failed: ', ERROR_MESSAGE());
    THROW;
END CATCH;
GO

SELECT AccountID, AccountHolder, Balance, AccountStatus
FROM dbo.BankAccounts
ORDER BY AccountID;
GO

/* 2. Deliberate failure after debit: rollback must restore both balances. */
DECLARE @BeforeSource DECIMAL(18,2);
DECLARE @BeforeDestination DECIMAL(18,2);

SELECT @BeforeSource = Balance FROM dbo.BankAccounts WHERE AccountID = 101;
SELECT @BeforeDestination = Balance FROM dbo.BankAccounts WHERE AccountID = 102;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 500.00
    WHERE AccountID = 101;

    PRINT 'Debit was performed inside the uncommitted transaction.';
    THROW 50010, 'Deliberate failure after debit for rollback demonstration.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 500.00
    WHERE AccountID = 102;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT('Expected failure caught: ', ERROR_MESSAGE());
END CATCH;

SELECT
    @BeforeSource AS SourceBalanceBefore,
    (SELECT Balance FROM dbo.BankAccounts WHERE AccountID = 101) AS SourceBalanceAfter,
    @BeforeDestination AS DestinationBalanceBefore,
    (SELECT Balance FROM dbo.BankAccounts WHERE AccountID = 102) AS DestinationBalanceAfter;
GO

/* 3. Savepoint: retain transfer but undo only the optional fee posting. */
DECLARE @Fee DECIMAL(18,2) = 25.00;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 200.00
    WHERE AccountID = 101 AND AccountStatus = 'ACTIVE';

    IF @@ROWCOUNT <> 1
        THROW 50020, 'Source account is not available.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 200.00
    WHERE AccountID = 102 AND AccountStatus = 'ACTIVE';

    IF @@ROWCOUNT <> 1
        THROW 50021, 'Destination account is not available.', 1;

    SAVE TRANSACTION BeforeFee;

    BEGIN TRY
        UPDATE dbo.BankAccounts
        SET Balance = Balance - @Fee
        WHERE AccountID = 101;

        INSERT INTO dbo.BankTransactions
            (FromAccountID, ToAccountID, Amount, TransactionType)
        VALUES (101, 102, @Fee, 'FEE');

        THROW 50022, 'Simulated fee-posting failure.', 1;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION BeforeFee;
            PRINT 'Fee step rolled back to savepoint; transfer is retained.';
        END
        ELSE
        BEGIN
            THROW;
        END
    END CATCH;

    INSERT INTO dbo.BankTransactions
        (FromAccountID, ToAccountID, Amount, TransactionType)
    VALUES (101, 102, 200.00, 'TRANSFER');

    COMMIT TRANSACTION;
    PRINT 'Main transfer committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT CONCAT('Transaction failed: ', ERROR_MESSAGE());
    THROW;
END CATCH;
GO

SELECT AccountID, AccountHolder, Balance
FROM dbo.BankAccounts
ORDER BY AccountID;

SELECT TransactionID, FromAccountID, ToAccountID, Amount, TransactionType
FROM dbo.BankTransactions
ORDER BY TransactionID;
GO


WITH AccountActivity AS
(
    SELECT
        TransactionID,
        FromAccountID AS AccountID,
        TransactionDate,
        -Amount AS Amount,
        TransactionType
    FROM dbo.BankTransactions

    UNION ALL

    SELECT
        TransactionID,
        ToAccountID AS AccountID,
        TransactionDate,
        Amount,
        TransactionType
    FROM dbo.BankTransactions
),
MonthlyStatement AS
(
    SELECT
        a.AccountID,
        a.TransactionID,
        a.TransactionDate,
        a.TransactionType,
        a.Amount,
        ROW_NUMBER() OVER
        (
            PARTITION BY a.AccountID, YEAR(a.TransactionDate), MONTH(a.TransactionDate)
            ORDER BY a.TransactionDate, a.TransactionID
        ) AS StatementRow,
        SUM(a.Amount) OVER
        (
            PARTITION BY a.AccountID
            ORDER BY a.TransactionDate, a.TransactionID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningNetMovement
    FROM AccountActivity AS a
)
SELECT
    AccountID,
    TransactionID,
    TransactionDate,
    TransactionType,
    Amount,
    StatementRow,
    LAG(RunningNetMovement, 1, 0) OVER
    (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS PreviousBalanceMovement,
    RunningNetMovement AS CurrentBalanceMovement
FROM MonthlyStatement
WHERE TransactionDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND TransactionDate < DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
ORDER BY AccountID, TransactionDate, TransactionID;
GO
