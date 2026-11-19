# Set 2 — Airline Seat Booking

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Transactions-green)

## Business Scenario

An airline must reserve a seat and create its booking record as one atomic operation. If multiple passengers attempt to reserve the same seat at nearly the same time, only one booking should succeed.

## Objectives and Implementation

| Task / Area | Implementation |
|---|---|
| Seat reservation | Uses a stored procedure to update a seat from `AVAILABLE` to `BOOKED` and insert the booking inside one transaction. |
| Concurrency control | Uses `UPDLOCK` and `HOLDLOCK`, a conditional update and a unique constraint on `(FlightID, SeatNo)`. |
| Fare ranking | Uses `RANK()` and `DENSE_RANK()` to rank passenger fares within each flight. |
| Running revenue | Uses `SUM() OVER` to calculate cumulative revenue per flight. |
| MongoDB equivalent | Uses a session transaction to conditionally update a seat document and insert a booking document. |

## Project Files

| File | Purpose |
|---|---|
| `airline_seat_booking.sql` | Consolidated SQL Server script. Creates/selects `AirlineBookingDB`, creates seat and booking tables, demonstrates atomic booking and runs fare-ranking and running-revenue reports. |
| `booking_txn.js` | MongoDB session transaction for seat reservation and booking insertion. |


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

Open `airline_seat_booking.sql` in SSMS and execute the complete file.

The script:

1. Creates `AirlineBookingDB` if it does not exist.
2. Switches to `AirlineBookingDB`.
3. Creates the flight-seat and booking tables.
4. Creates and executes the `dbo.BookSeat` stored procedure.
5. Demonstrates a successful booking.
6. Runs fare ranking using `RANK()` and `DENSE_RANK()`.
7. Calculates running revenue per flight using a windowed `SUM()`.

The script drops and recreates its sample tables and stored procedure when rerun. Use it in a learning database.

## Run the MongoDB Example

Set your MongoDB connection string and execute:

**Windows PowerShell:**

```powershell
$env:MONGODB_URI="mongodb://localhost:27017/?replicaSet=rs0"
node booking_txn.js
```

**macOS / Linux:**

```bash
export MONGODB_URI="mongodb://localhost:27017/?replicaSet=rs0"
node booking_txn.js
```

The JavaScript example reserves a seat only if its status is `AVAILABLE`, then inserts the booking in the same transaction.

## Concurrency Test

Read [`concurrency_explanation.md`](./concurrency_explanation.md) before attempting the two-session test.

Use two separate SSMS query windows and attempt to book the same test seat at nearly the same time. The expected result is that one request commits and the other fails after the seat is no longer available.

The unique constraint on `(FlightID, SeatNo)` provides an additional safeguard against duplicate booking records.

- The SQL script targets Microsoft SQL Server T-SQL.
- A prior availability `SELECT` by itself is not sufficient to prevent concurrent double booking.
- `RANK()` leaves gaps after tied positions; `DENSE_RANK()` does not.

