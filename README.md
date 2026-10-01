# MIT 8103 Advanced Database Systems: Database Portfolio

**Student:** ONYEKACHI ELVIS 
**Programme:** Master of Information Technology, MIVA Open University | **Session:** 2026/2027, First Semester
**Case study:** MafixxStores (e-commerce platform)

---

## 1. Selected organisation
**MafixxStores** is an e-commerce platform that sells phones, computing, electronics, fashion, home goods, beauty, groceries and sports items. The same case study is used in all five portfolios. All data is synthetic.

| Item | Description |
|---|---|
| Users of the database | Customers, sales staff, inventory managers, finance team, analysts |
| Major data stored | Customers, products, categories, suppliers, orders, order items, payments, deliveries, stock changes, reviews |
| Key operations | Add products, place orders, update stock, process payments, track deliveries, sales reporting |

**Starting point:** the repository owner supplied a MySQL Workbench EER model (`MafixxStores.mwb.bak`, 6 tables). I reviewed it in `portfolio-1-database-design/00_baseline_model_review.md` and corrected and extended it. Everything inside `advanced-database-portfolio/` is my own work.

## 2. Repository structure
```
advanced-database-portfolio/
├── portfolio-1-database-design/
├── portfolio-2-query-optimisation/
├── portfolio-3-transactions-concurrency/
├── portfolio-4-nosql/
├── portfolio-5-distributed-cloud/
└── README.md
```
Each folder has its own README, scripts, outputs and a `screenshots/` folder.

## 3. Tools used
PostgreSQL and pgAdmin, MongoDB and Compass, Docker Desktop , Git, VS Code. 

## 4. Summary of the five portfolios

### Portfolio 1: Database Design and Modelling
- ER diagram with 9 entities, and a relational schema in PostgreSQL (`01_schema.sql`).
- Primary, foreign and composite keys, plus `UNIQUE`, `NOT NULL`, `CHECK` and `DEFAULT` constraints.
- Normalised to 3NF, with two justified denormalisations (`order_items.unit_price` and `orders.total_amount`).
- Loaded 8 categories, 15 suppliers, 2,000 customers, 200 products, 50,000 orders, 109,828 order items, 50,000 payments and 35,018 deliveries.
- Verified: order totals match their items, and invalid data (negative price, duplicate email, missing customer, negative stock) is rejected.

### Portfolio 2: Query Processing and Optimisation
- Business queries (joins, aggregation, subqueries) plus advanced SQL (CTE, window function, view).
- `EXPLAIN (ANALYZE, BUFFERS)` plans captured **before and after** indexing (`results_before.txt`, `results_after.txt`).
- Optimisations: B-tree indexes, a composite index, a partial index, a trigram index, and a materialized view for monthly revenue.
- Results: [Q1: __ ms to __ ms] [Q3: __ ms to __ ms] [Q5: __ ms to __ ms]. Q8 reads most of the table, so a full scan is correctly kept.
- Trade-off: indexes cost storage and slow writes; the materialized view goes stale until refreshed.

### Portfolio 3: Transactions and Concurrency
- `BEGIN`, `COMMIT`, `ROLLBACK` and `SAVEPOINT` demonstrated with a stock-safe `place_order()` function (all or nothing).
- Isolation: under `REPEATABLE READ`, a session kept its snapshot while another changed the row, and PostgreSQL then refused a conflicting update (`could not serialize access`).
- Control mechanisms: `SELECT ... FOR UPDATE` row locks and constraint protection of stock.
- Evidence: `output_01.txt` and the screenshots.

### Portfolio 4: NoSQL and Advanced Data Models
- Document model in **MongoDB** for the same case study: `products`, `customers`, `orders` (10,000-order sample, with items, payment and delivery **embedded**) and `reviews` (referenced, because it grows without limit).
- CRUD operations, aggregation pipelines (`$group`, `$unwind`, `$lookup`), indexes with `explain()` (COLLSCAN to IXSCAN), and schema validation (`Document failed validation`).
- Suitability: MongoDB fits the catalogue and order history; PostgreSQL stays better for payments and stock, where strict ACID matters.

### Portfolio 5: Distributed and Cloud Database Exercise
- **Sharding:** MongoDB cluster in Docker (config server, 2 shards, `mongos` router). 10,000 orders distributed across both shards. A query with the shard key contacts one shard; without it, all shards.
- **Replication:** [3-node MongoDB replica set with 1 primary and 2 secondaries: DELETE THIS LINE IF YOU DID NOT COMPLETE IT].
- Discussion of availability, consistency (CAP trade-off) and cloud deployment in `portfolio-5-distributed-cloud/DISCUSSION.md`.

## 5. How to reproduce
| Portfolio | Run |
|---|---|
| 1 | `01_schema.sql`, `02_import_data.sql`, `03_verify.sql` (inside the folder, database `mafixx`) |
| 2 | `01_queries.sql`, then `02_explain_before.sql`, `03_create_indexes.sql`, `04_explain_after.sql`, `05_advanced_sql.sql` |
| 3 | `00_setup.sql`, `01_commit_rollback.sql`, then the two-session demos in `02_isolation_levels.md` and `03_concurrency_control.md` |
| 4 | Import `data/*.json` in Compass, then run `01`, `02`, `03` `.js` scripts in mongosh |
| 5 | `docker compose up -d` in `mongo-sharding/` (and `mongo-replica-set/`), then the commands in each folder's README |

## AI Use Declaration
- **Tool used:** Claude (Anthropic).
- **Used for:** explaining concepts, generating starter SQL and MongoDB scripts, synthetic data generator, and README and report templates.
- **How I verified it:** I ran every script on my own PostgreSQL, MongoDB and Docker setup, took the screenshots myself, fixed errors I found (for example [LIST YOUR REAL FIXES]), and checked the original EER model myself in MySQL Workbench. I can explain every part of this portfolio.

*(Edit this so it is exactly true for you.)*

## References
- Datasets: synthetic, generated by `portfolio-1-database-design/data/generate_data.py`