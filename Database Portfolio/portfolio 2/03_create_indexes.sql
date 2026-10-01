-- =====================================================================
-- Part C: Optimisation. Each index is chosen for a specific query.
-- =====================================================================
-- Q1/Q4: find a customer's orders without scanning all 50,000 orders (also speeds up the FK join)
CREATE INDEX idx_orders_customer_id ON orders (customer_id);

-- Q2: composite index. Equality column (status) first, range column (order_date) second.
CREATE INDEX idx_orders_status_date ON orders (status, order_date);

-- Q3/Q8: find order lines by product (the PK (order_id, product_id) cannot help here because
-- product_id is the SECOND column of that composite key)
CREATE INDEX idx_order_items_product_id ON order_items (product_id);

-- Q7: partial index; only the few low-stock rows are indexed, so it stays tiny
CREATE INDEX idx_products_low_stock ON products (stock_qty) WHERE stock_qty < 40;

-- Q6: a normal B-tree cannot help with ILIKE '%text%'. A trigram GIN index can.
-- (pg_trgm is a standard PostgreSQL extension. If this line errors, skip Q6 and explain why in your report.)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING gin (product_name gin_trgm_ops);

-- Q5: no ordinary index fixes a full-table aggregation, so we PRE-COMPUTE it (materialized view).
DROP MATERIALIZED VIEW IF EXISTS mv_monthly_revenue;
CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT date_trunc('month', o.order_date)::date AS month,
       COUNT(*)            AS orders,
       SUM(o.total_amount) AS revenue
FROM orders o
JOIN payments pay ON pay.order_id = o.order_id
WHERE pay.payment_status = 'Successful'
GROUP BY 1;
CREATE UNIQUE INDEX idx_mv_monthly_revenue ON mv_monthly_revenue (month);

ANALYZE;   -- update statistics so the planner knows the new indexes exist

\qecho === Indexes now present (screenshot this) ===
SELECT tablename, indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;
