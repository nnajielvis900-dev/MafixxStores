# Portfolio 2: Performance Results

Fill in the table from `results_before.txt` and `results_after.txt`
(take the number next to **"Execution Time"** at the bottom of each plan, and the scan type, e.g. `Seq Scan`, `Index Scan`, `Bitmap Index Scan`).

| Query | Purpose | Plan BEFORE | Time BEFORE (ms) | Optimisation used | Plan AFTER | Time AFTER (ms) | Improvement |
|------|---------|-------------|------------------|-------------------|------------|-----------------|-------------|
| Q1 | Customer order history | | | idx_orders_customer_id | | | |
| Q2 | Shipped orders since Aug 2026 | | | idx_orders_status_date (composite) | | | |
| Q3 | Units sold for one product | | | idx_order_items_product_id | | | |
| Q4 | 4-table join for one customer | | | idx_orders_customer_id | | | |
| Q5 | Monthly revenue | | | Materialized view | | | |
| Q6 | Product name search | | | GIN trigram index | | | |
| Q7 | Low-stock alert | | | Partial index | | | |
| Q8 | Top 10 products by revenue | | | idx_order_items_product_id (may not be used) | | | |

## Analysis (write this in your own words, 1 short paragraph each)
- **Where did the biggest improvement happen, and why?** (Hint: a Seq Scan reads every row; an Index Scan jumps straight to matching rows.)
- **Which query did NOT improve, and why?** (Hint: if a query must read most of a table anyway, PostgreSQL correctly prefers a sequential scan. That is the planner being smart, not the index failing.)
- **Trade-offs of indexes:** faster reads, but extra disk space and slower INSERT/UPDATE because each index must be maintained. The materialized view must be refreshed (`REFRESH MATERIALIZED VIEW mv_monthly_revenue;`) to show new data.
