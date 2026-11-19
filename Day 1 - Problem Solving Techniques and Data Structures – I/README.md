# Day 1 — Problem Solving Techniques and Data Structures I

![Language](https://img.shields.io/badge/language-Python-blue)
![Focus](https://img.shields.io/badge/focus-DSA-orange)
![Datasets](https://img.shields.io/badge/data-synthetic-lightgrey)

This day contains three practical problem-solving exercises based on common business workflows. Each set demonstrates searching, sorting, hashing, stacks, queues and algorithm-design techniques using Python.

## Project Overview

| Set | Business Scenario | Main Concepts |
|---|---|---|
| [Set 1 — Retail Order Desk](./Set%201%20-%20Retail%20Order%20Desk/) | Order retrieval, dispatch ranking and duplicate-order checks | Linear and binary search, bubble sort, merge sort, hashing, stack, queue, greedy and dynamic programming |
| [Set 2 — Retail Banking Transaction Review](./Set%202%20-%20Retail%20Banking%20Transaction%20Review/) | Transaction lookup, statement ordering and duplicate-posting review | Binary search, insertion sort, merge sort, hashing, queue, stack, divide and conquer |
| [Set 3 — Hospital Appointment Desk](./Set%203%20-%20Hospital%20Appointment%20Desk/) | Patient lookup, appointment prioritization and duplicate-slot prevention | Linear and binary search, selection sort, quick sort, hashing, queue, stack, dynamic programming |

## Repository Structure

```text
Day 1/
├── README.md
├── Set 1 - Retail Order Desk/
│   ├── README.md
│   ├── main.py
│   ├── orders.csv
│   ├── execution_output.txt
│   ├── complexity_and_design.md
│   └── sorting_trace.md
├── Set 2 - Retail Banking Transaction Review/
│   ├── README.md
│   ├── main.py
│   ├── transactions.csv
│   ├── execution_output.txt
│   ├── complexity_and_design.md
│   └── stability_trace.md
└── Set 3 - Hospital Appointment Desk/
    ├── README.md
    ├── main.py
    ├── appointments.csv
    ├── execution_output.txt
    ├── complexity_and_design.md
    └── sorting_trace.md
```

## Getting Started

### Requirements

- Python 3.9 or newer
- No external Python packages are required.

### Run an Assignment

Open a terminal in the folder for the set you want to run:

```bash
python main.py
```

Run the command from inside the relevant set folder. Each program reads its CSV input file from that same folder.

## Included Documentation

Each set includes:

- **`main.py`** — Python implementation of the five assignment tasks.
- **CSV dataset** — Generated input data for testing.

- Runtime measurements depend on hardware, Python version and system load. Compare algorithms on the same machine.
- Binary search requires the input to be sorted by the search key.
