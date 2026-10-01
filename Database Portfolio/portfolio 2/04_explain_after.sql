-- =====================================================================
-- Part D: Plans AFTER optimisation. Run:
--   psql -U postgres -d mafixx -f 04_explain_after.sql -o results_after.txt
-- Look for "Index Scan" / "Bitmap Index Scan" and the new "Execution Time".
-- =====================================================================
\qecho ===== Q1 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT order_id, order_date, status, total_amount FROM orders WHERE customer_id = 249 ORDER BY order_date DESC;

\qecho ===== Q2 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT order_id, customer_id, order_date, total_amount FROM orders WHERE status = 'Shipped' AND order_date >= '2026-08-01';

\qecho ===== Q3 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT SUM(quantity), COUNT(DISTINCT order_id) FROM order_items WHERE product_id = 42;

\qecho ===== Q4 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.unit_price FROM customers c JOIN orders o ON o.customer_id = c.customer_id JOIN order_items oi ON oi.order_id = o.order_id JOIN products p ON p.product_id = oi.product_id WHERE c.customer_id = 249 ORDER BY o.order_date DESC;

\qecho ===== Q5 AFTER (now reads the pre-computed materialized view) =====
EXPLAIN (ANALYZE, BUFFERS) SELECT month, orders, revenue FROM mv_monthly_revenue ORDER BY month;

\qecho ===== Q6 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT product_id, product_name, unit_price FROM products WHERE product_name ILIKE '%tecno%';

\qecho ===== Q7 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT product_id, product_name, stock_qty FROM products WHERE stock_qty < 40 ORDER BY stock_qty;

\qecho ===== Q8 AFTER =====
EXPLAIN (ANALYZE, BUFFERS) SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue FROM order_items oi JOIN orders o ON o.order_id = oi.order_id JOIN products p ON p.product_id = oi.product_id WHERE o.status = 'Delivered' GROUP BY p.product_id, p.product_name ORDER BY revenue DESC LIMIT 10;

-- =====================================================================
-- Part D2 (optional but valuable): small tables can ignore indexes.
-- "products" has only 200 rows, so PostgreSQL may still choose a Seq Scan for Q6/Q7 because reading
-- 200 rows is cheaper than using an index. That is the planner being smart. To PROVE the index works,
-- we temporarily forbid sequential scans and look at the plan again.
-- =====================================================================
SET enable_seqscan = off;
\qecho ===== Q6 with Seq Scan disabled (shows the trigram index CAN be used) =====
EXPLAIN (ANALYZE) SELECT product_id, product_name, unit_price FROM products WHERE product_name ILIKE '%tecno%';
\qecho ===== Q7 with Seq Scan disabled (shows the partial index CAN be used) =====
EXPLAIN (ANALYZE) SELECT product_id, product_name, stock_qty FROM products WHERE stock_qty < 40 ORDER BY stock_qty;
RESET enable_seqscan;
