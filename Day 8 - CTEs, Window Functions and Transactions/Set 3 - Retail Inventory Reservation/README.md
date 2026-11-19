# Set 3 — Retail Inventory Reservation

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Atomic%20Updates-green)

## Business Scenario

An online retailer reserves stock when an order is placed. The inventory update, order creation and order-line insertion must succeed together. If stock is insufficient or the order cannot be completed, the operation must not leave inventory in an inconsistent state.

## Objectives and Implementation

| Task / Area | Implementation |
|---|---|
| Stock reservation | Validates available stock and decrements inventory inside a SQL Server transaction. |
| Order creation | Creates the order and its order-line records in the same transaction as the stock update. |
| Rollback demonstration | Requests more stock than is available and verifies that stock and order records remain unchanged. |
| Stock analysis | Uses a correlated subquery to find products whose stock is below their category's average. |
| Sales reporting | Uses a CTE and window functions including `ROW_NUMBER()`, `LAG()` and `LEAD()` for product/category ranking and month-on-month comparison. |
| MongoDB equivalent | Uses a conditional single-document update with `$inc` to reserve stock only when sufficient quantity remains. |

## Project Files

| File | Purpose |
|---|---|
| `retail_inventory_reservation.sql` | Consolidated SQL Server script. Creates/selects `RetailInventoryDB`, creates sample inventory/order tables, demonstrates reservation and rollback, and runs stock and sales reports. |
| `stock_update.js` | MongoDB single-document atomic stock decrement using `$inc`. |


## Requirements

- SQL Server and SSMS or Azure Data Studio
- Node.js
- MongoDB server
- MongoDB Node.js driver

Install the driver:

```bash
npm install mongodb
```

The provided MongoDB example updates one inventory document atomically. It does not require a multi-document transaction or replica set for this operation.

## Run the SQL Script

Open `retail_inventory_reservation.sql` in SSMS and execute the complete file.

The script:

1. Creates `RetailInventoryDB` if it does not exist.
2. Switches to `RetailInventoryDB`.
3. Creates sample product, order and order-line tables.
4. Reserves stock and creates an order within one transaction.
5. Demonstrates rollback when the requested stock quantity is unavailable.
6. Runs a correlated subquery to identify below-average category stock.
7. Creates sample sales data and runs product/category ranking and month-on-month reports.

The script drops and recreates its sample tables when rerun. Use it in a learning database.

## Run the MongoDB Example

Set your MongoDB connection string and execute:

**Windows PowerShell:**

```powershell
$env:MONGODB_URI="mongodb://localhost:27017"
node stock_update.js
```

**macOS / Linux:**

```bash
export MONGODB_URI="mongodb://localhost:27017"
node stock_update.js
```

The script initializes a sample inventory document if needed, then decrements stock only when the current stock is greater than or equal to the requested quantity.

## MongoDB Design Note

Read [`mongo_transactions.md`](./mongo_transactions.md) for the distinction between:

- **Single-document atomic update:** suitable when the inventory document is the only document that must change.
- **Multi-document transaction:** appropriate when stock, order, order-line and other related documents must commit or roll back together.


- The SQL script targets Microsoft SQL Server T-SQL.
- The conditional MongoDB update prevents stock from becoming negative for the requested decrement.
- Keep multi-document transactions short and avoid placing slow external operations inside them.

