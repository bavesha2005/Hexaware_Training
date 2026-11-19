# Set 3 — Hospital Appointment Desk

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![Records](https://img.shields.io/badge/appointments-20%2C000-informational)

## Business Scenario

A multi-speciality hospital manages appointments through a shared roster. Receptionists need to find patient records, doctors need appointments ordered by urgency and arrival time, and the system must prevent the same patient from being booked into the same time slot more than once.

## Objectives and Implementation

| Task | Implementation |
|---|---|
| 1. Patient lookup | Implements linear and binary search by `patientId` and measures the time for 1,000 lookups. |
| 2. Appointment sorting | Implements selection sort and quick sort, ordering by urgency and then arrival time; compares swap counts and runtime. |
| 3. Double-booking detection | Uses a hash set with a composite patient-and-slot key to identify repeated bookings. |
| 4. Walk-in and history structures | Implements a FIFO queue for walk-in tokens and a LIFO stack for recently viewed patients. |
| 5. Shift scheduling | Uses dynamic programming to find the maximum number of mutually compatible appointments and compares the result with an earliest-finish-time greedy baseline. |

## Project Files

| File | Purpose |
|---|---|
| `main.py` | Contains all five task implementations and comparisons. |
| `appointments.csv` | Synthetic dataset containing 20,000 appointment records. |

## Requirements

- Python 3.9 or newer
- No third-party packages required

## Run

From this directory, execute:

```bash
python main.py
```

- The duplicate-booking check uses the composite key `(patientId, start, end)`.
- All appointment records are generated sample data and contain no real patient information.
- Runtime and swap-count results depend on the supplied data and execution environment.
