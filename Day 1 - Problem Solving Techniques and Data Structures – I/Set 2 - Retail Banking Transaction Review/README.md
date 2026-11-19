# Set 2 — Retail Banking Transaction Review

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![Search IDs](https://img.shields.io/badge/search%20IDs-100%2C000-informational)

## Business Scenario

A retail bank's operations team reviews daily card transactions. Auditors need fast transaction-ID lookups, customers need statements ordered by posting date, and the bank needs to identify duplicate postings as early as possible.

## Objectives and Implementation

| Task | Implementation |
|---|---|
| 1. Transaction lookup | Compares binary search and linear search on 100,000 sorted transaction IDs and reports comparison counts for representative best, average-position and unsuccessful worst-case searches. |
| 2. Statement ordering | Implements insertion sort and merge sort by posting date, with stable ordering for equal timestamps. |
| 3. Duplicate postings | Groups transactions by account, amount and merchant, then checks whether matching postings are within 60 seconds. |
| 4. Review and reversal structures | Implements a FIFO queue for the manual-review backlog and a LIFO stack for reversing the most recent adjustment. |
| 5. Daily amount range | Uses divide and conquer to find the minimum and maximum transaction amounts and compares the result with a brute-force scan. |

## Project Files

| File | Purpose |
|---|---|
| `main.py` | Contains all five task implementations and comparisons. |
| `transactions.csv` | Synthetic transaction records used for statement sorting, duplicate checks and min/max analysis. |

## Requirements

- Python 3.9 or newer
- No third-party packages required

## Run

From this directory, execute:

```bash
python main.py
```

- The duplicate-detection implementation sorts transactions by time and checks prior records in each matching composite-key group. A heavily repeated key can increase candidate comparisons.
- Runtime measurements vary by machine and Python version.
