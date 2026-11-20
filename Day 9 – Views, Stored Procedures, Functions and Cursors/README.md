# Day 9 — Views, Stored Procedures, Functions and Cursors

This repository contains three SQL Server and MongoDB practical exercises.

## Projects

| Set | Business scenario | Main concepts |
|---|---|---|
| [Set 1 — Retail Order Fulfilment](./Set%201%20-%20Retail%20Order%20Fulfilment/) | Centralise order placement, stock validation and overdue follow-up | Views, `WITH CHECK OPTION`, transactional stored procedure, scalar/inline TVF, cursor and set-based insert, MongoDB view |
| [Set 2 — Insurance Premium Processing](./Set%202%20-%20Insurance%20Premium%20Processing/) | Standardise policy renewal and lapsed-policy handling | Policy view, renewal procedure and audit, discount function, agent quote TVF, cursor and set-based update, MongoDB view |
| [Set 3 — Telecom Low-Balance Follow-up](./Set%203%20-%20Telecom%20Low-Balance%20Follow-up/) | Recharge prepaid subscribers and notify low balances | Filtered views, transactional recharge procedure, validity function, last-five-recharges TVF, cursor and set-based notification insert, MongoDB view |

## Folder structure

Each set contains only:
- `README.md` — run instructions and overview.
- `sql_server.sql` — all SQL Server work in one executable file.
- `mongo_view.js` — MongoDB view creation.

## Execution
For each set, run `sql_server.sql` once in SSMS. Run `mongo_view.js` separately in `mongosh`. 


