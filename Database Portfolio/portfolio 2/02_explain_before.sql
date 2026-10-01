-- =====================================================================
-- Part B: BASELINE execution plans (before adding any index).
-- Only primary-key / unique indexes exist at this point.
-- Run:  psql -U postgres -d mafixx -f 02_explain_before.sql -o results_before.txt
-- Then open results_before.txt and screenshot the key lines
-- (look for "Seq Scan" and "Execution Time").
-- =====================================================================
\qecho ===== Q1 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT order_id, order_date, status, total_amount FROM orders WHERE customer_id = 249 ORDER BY order_date DESC;

\qecho ===== Q2 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT order_id, customer_id, order_date, total_amount FROM orders WHERE status = 'Shipped' AND order_date >= '2026-08-01';

\qecho ===== Q3 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT SUM(quantity), COUNT(DISTINCT order_id) FROM order_items WHERE product_id = 42;

\qecho ===== Q4 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.unit_price FROM customers c JOIN orders o ON o.customer_id = c.customer_id JOIN order_items oi ON oi.order_id = o.order_id JOIN products p ON p.product_id = oi.product_id WHERE c.customer_id = 249 ORDER BY o.order_date DESC;

\qecho ===== Q5 BEFORE (aggregation over whole table) =====
EXPLAIN (ANALYZE, BUFFERS) SELECT date_trunc('month', o.order_date)::date AS month, COUNT(*), SUM(o.total_amount) FROM orders o JOIN payments pay ON pay.order_id = o.order_id WHERE pay.payment_status = 'Successful' GROUP BY 1 ORDER BY 1;

\qecho ===== Q6 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT product_id, product_name, unit_price FROM products WHERE product_name ILIKE '%tecno%';

\qecho ===== Q7 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT product_id, product_name, stock_qty FROM products WHERE stock_qty < 40 ORDER BY stock_qty;

\qecho ===== Q8 BEFORE =====
EXPLAIN (ANALYZE, BUFFERS) SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue FROM order_items oi JOIN orders o ON o.order_id = oi.order_id JOIN products p ON p.product_id = oi.product_id WHERE o.status = 'Delivered' GROUP BY p.product_id, p.product_name ORDER BY revenue DESC LIMIT 10;
