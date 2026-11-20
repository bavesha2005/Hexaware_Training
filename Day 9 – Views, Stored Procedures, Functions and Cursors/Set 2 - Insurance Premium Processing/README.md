# Insurance Premium Processing

## Files
- `sql_server.sql` — complete SQL Server solution: schema/sample data, views, stored procedures, functions, cursor and set-based alternative.
- `mongo_view.js` — MongoDB view using `db.createView()`.
- `comparison.md` — cursor vs set-based explanation and relevant comparison notes.
- `screenshots/` — add screenshots from SSMS and mongosh.

## Run instructions
1. Open `sql_server.sql` in SSMS and execute the complete script.
2. Run `mongo_view.js` in `mongosh` after creating/loading the sample documents described in its comments.
3. Capture your execution results and place them in `screenshots/`.

The SQL file is ordered so the database objects are created before they are used. These are self-contained learning examples with sample data; review security and concurrency requirements before using similar logic in production.
