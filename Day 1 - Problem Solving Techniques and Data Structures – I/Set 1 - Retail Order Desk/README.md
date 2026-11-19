# Set 1 — Retail Order Desk

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![Records](https://img.shields.io/badge/orders-50%2C000-informational)

## Business Scenario

An online retailer processes approximately 50,000 orders each day. Support agents need to retrieve orders quickly, the warehouse needs orders ranked by amount for dispatch, and finance needs to identify duplicate submissions before payment capture.

## Objectives and Implementation

| Task | Implementation |
|---|---|
| 1. Order lookup | Implements linear search and binary search by `orderId`, then measures their lookup time. |
| 2. Order ranking | Implements bubble sort and merge sort in descending order by amount, and compares them with Python's built-in `sorted()` on 10,000 records. |
| 3. Duplicate detection | Uses a dictionary with `(customerId, amount, minute)` as the composite key. |
| 4. Undo and dispatch | Implements a custom stack for undo history and a custom queue for dispatch, then demonstrates Python's built-in list/deque equivalents. |
| 5. Refund calculation | Compares greedy change-making with a dynamic-programming solution. |

## Project Files

| File | Purpose |
|---|---|
| `main.py` | Contains all five task implementations and benchmark output. |
| `orders.csv` | Synthetic dataset containing 50,000 orders with `orderId`, `customerId`, `amount` and `createdAt`. |

## Requirements

- Python 3.9 or newer
- No third-party packages required

## Run

From this directory, execute:

```bash
python main.py
```

- Binary search is run on an order-ID-sorted view of the data.
- The duplicate rule groups records by customer, amount and the minute portion of `createdAt`.
- Benchmark timings are machine-dependent and should be interpreted as a comparison on the same system.
- The dataset is synthetic and contains no real order or customer information.
