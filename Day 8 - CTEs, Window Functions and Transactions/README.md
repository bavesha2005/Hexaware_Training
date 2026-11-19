# Day 8 — CTEs, Window Functions and Transactions

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-JavaScript-green)
![Topics](https://img.shields.io/badge/focus-Transactions%20%7C%20CTEs%20%7C%20Window%20Functions-orange)

This practical contains three business-oriented database exercises. Each set combines SQL Server transaction processing and reporting with a MongoDB implementation or comparison.

## Project Overview

| Set | Business Scenario | Main Concepts |
|---|---|---|
| [Set 1 — Bank Funds Transfer](./Set%201%20-%20Bank%20Funds%20Transfer/) | Transfer money between accounts reliably | Transactions, `COMMIT`, `ROLLBACK`, savepoints, `TRY...CATCH`, CTEs, `ROW_NUMBER`, `LAG`, isolation levels, MongoDB multi-document transactions |
| [Set 2 — Airline Seat Booking](./Set%202%20-%20Airline%20Seat%20Booking/) | Prevent two passengers from booking the same seat | Atomic booking, locking, concurrency, unique constraints, `RANK`, `DENSE_RANK`, running totals, MongoDB session transactions |
| [Set 3 — Retail Inventory Reservation](./Set%203%20-%20Retail%20Inventory%20Reservation/) | Reserve stock as part of an order and preserve inventory consistency | Transactions, rollback, correlated subqueries, CTEs, `ROW_NUMBER`, `LAG`, `LEAD`, MongoDB atomic `$inc` |

## Repository Structure

The final consolidated SQL scripts are:

```text
Day 8/
├── README.md
├── Set 1 - Bank Funds Transfer/
│   ├── README.md
│   ├── bank_funds_transfer.sql
│   └── transaction.js
├── Set 2 - Airline Seat Booking/
│   ├── README.md
│   ├── airline_seat_booking.sql
│   └── booking_txn.js
└── Set 3 - Retail Inventory Reservation/
    ├── README.md
    ├── retail_inventory_reservation.sql
    └── stock_update.js
```

## Requirements

### SQL Server

- Microsoft SQL Server with support for T-SQL transactions, `TRY...CATCH`, CTEs and window functions.
- SQL Server Management Studio (SSMS) or Azure Data Studio.

### MongoDB and Node.js

- Node.js
- MongoDB server
- Official MongoDB Node.js driver

Install the driver in the project environment:

```bash
npm install mongodb
```

The Bank Funds Transfer and Airline Seat Booking examples use multi-document transactions. Run them against a MongoDB replica set or sharded cluster. The Retail Inventory Reservation example uses a single-document atomic update and does not require a multi-document transaction.

## Running the SQL Scripts

Open the relevant consolidated `.sql` file in SSMS and execute the complete script:

| Set | SQL file | Database created/selected |
|---|---|---|
| 1 | `bank_funds_transfer.sql` | `BankFundsDB` |
| 2 | `airline_seat_booking.sql` | `AirlineBookingDB` |
| 3 | `retail_inventory_reservation.sql` | `RetailInventoryDB` |

Each script creates its database if it does not already exist, switches to it, and creates/repopulates its sample tables. 
## Running the MongoDB Examples

Set the `MONGODB_URI` environment variable to your MongoDB connection string before running the JavaScript file.

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

Use the corresponding JavaScript filename in each set:

- Set 1: `transaction.js`
- Set 2: `booking_txn.js`
- Set 3: `stock_update.js`

Change the connection string to match your MongoDB deployment.

- The SQL scripts use Microsoft SQL Server T-SQL syntax
- Multi-document MongoDB transactions require a replica set or sharded cluster.
- Keep transactions short and avoid placing slow external operations inside them.
- Concurrency demonstrations should be performed in separate SQL Server query windows, following the relevant explanation file.
