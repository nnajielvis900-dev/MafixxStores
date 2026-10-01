# Portfolio 2: Query Processing and Optimisation

## What was implemented
- 8 business queries (`01_queries.sql`) covering filtering, joins, aggregation, search and reporting.
- **Baseline execution plans** (`02_explain_before.sql` → `results_before.txt`) using `EXPLAIN (ANALYZE, BUFFERS)`.
- **Optimisation** (`03_create_indexes.sql`): B-tree, composite, partial and GIN trigram indexes, plus a materialized view.
- **After-optimisation plans** (`04_explain_after.sql` → `results_after.txt`).
- Advanced SQL (`05_advanced_sql.sql`): a view, CTE, window functions (RANK, running total).
- Analysis table: `PERFORMANCE_RESULTS.md`.

## How to run
```
psql -U postgres -d mafixx -f 01_queries.sql -o results_queries.txt
psql -U postgres -d mafixx -f 02_explain_before.sql -o results_before.txt
psql -U postgres -d mafixx -f 03_create_indexes.sql
psql -U postgres -d mafixx -f 04_explain_after.sql -o results_after.txt
psql -U postgres -d mafixx -f 05_advanced_sql.sql -o results_advanced.txt
```

## Testing
Each query was run before and after optimisation; execution times and plan types are compared in `PERFORMANCE_RESULTS.md`.

## Design choices and challenges
[Your own words: which index gave the biggest gain and why; which query did not improve and why; index trade-offs.]
