# Set 1 — Bank Funds Transfer

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Transactions-green)

## Business Scenario

A bank must debit one account and credit another as a single atomic operation. Both balance changes must succeed together, or neither change should be retained.

## Objectives and Implementation

| Task / Area | Implementation |
|---|---|
| Atomic fund transfer | Validates that both accounts exist, are active and that the source account has sufficient funds before updating balances. |
| Transaction rollback | Deliberately raises an error after a debit to demonstrate that the uncommitted change is rolled back. |
| Savepoint | Uses `SAVE TRANSACTION` so a failed optional fee-posting step can be rolled back without discarding the main transfer. |
| Monthly statement | Uses a CTE with `ROW_NUMBER()` and `LAG()` to organize and compare transaction activity. |
| MongoDB equivalent | Uses a session transaction to update two account documents and insert a transaction/ledger record. |
| Isolation levels | Explains `READ COMMITTED` and `SNAPSHOT`, with a two-session demonstration. |

## Project Files

| File | Purpose |
|---|---|
| `bank_funds_transfer.sql` | Consolidated SQL Server script. Creates/selects `BankFundsDB`, creates sample tables, demonstrates transfer, rollback and savepoint behavior, and runs the statement report. |
| `transaction.js` | MongoDB session transaction for a two-account transfer. |


## Requirements

- SQL Server and SSMS or Azure Data Studio
- Node.js
- MongoDB replica set or sharded cluster for the multi-document transaction
- MongoDB Node.js driver

Install the driver:

```bash
npm install mongodb
```

## Run the SQL Script

Open `bank_funds_transfer.sql` in SSMS and execute the complete file.

The script:

1. Creates `BankFundsDB` if it does not exist.
2. Switches to `BankFundsDB`.
3. Creates sample account and transaction tables.
4. Demonstrates a successful transfer.
5. Demonstrates rollback after a deliberate failure.
6. Demonstrates a savepoint for the optional fee step.
7. Runs the monthly statement report.

The script drops and recreates its sample tables when rerun. Use it in a learning database.

## Run the MongoDB Example

Set your MongoDB connection string and execute:

**Windows PowerShell:**

```powershell
$env:MONGODB_URI="mongodb://localhost:27017/?replicaSet=rs0"
node transaction.js
```

**macOS / Linux:**

```bash
export MONGODB_URI="mongodb://localhost:27017/?replicaSet=rs0"
node transaction.js
```

The MongoDB example uses a multi-document transaction. A standalone MongoDB server does not support this transaction pattern.


- The SQL script targets Microsoft SQL Server T-SQL.
- The transaction uses row locks while validating and updating account records.
- The MongoDB transaction changes multiple documents and inserts a ledger record atomically.

