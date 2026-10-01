-- =====================================================================
-- Portfolio 2 : Query Processing and Optimisation  (MafixxStores)
-- Part A: the business queries (run these first and screenshot results)
-- =====================================================================
\qecho === Q1: Order history of one customer (customer 249) ===
SELECT order_id, order_date, status, total_amount
FROM orders
WHERE customer_id = 249
ORDER BY order_date DESC;

\qecho === Q2: Shipped orders placed since 1 Aug 2026 (operations team tracking) ===
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE status = 'Shipped' AND order_date >= '2026-08-01';

\qecho === Q3: How many units of product 42 have been sold, and to how many orders? ===
SELECT SUM(quantity) AS units_sold, COUNT(DISTINCT order_id) AS in_orders
FROM order_items
WHERE product_id = 42;

\qecho === Q4: Customer order detail with items and product names (join of 4 tables) ===
SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price) AS line_total
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products p     ON p.product_id  = oi.product_id
WHERE c.customer_id = 249
ORDER BY o.order_date DESC;

\qecho === Q5: Monthly revenue of successfully paid orders (heavy aggregation) ===
SELECT date_trunc('month', o.order_date)::date AS month,
       COUNT(*)            AS orders,
       SUM(o.total_amount) AS revenue
FROM orders o
JOIN payments pay ON pay.order_id = o.order_id
WHERE pay.payment_status = 'Successful'
GROUP BY 1
ORDER BY 1;

\qecho === Q6: Product name search (customer types "phone" in the search box) ===
SELECT product_id, product_name, unit_price
FROM products
WHERE product_name ILIKE '%tecno%';

\qecho === Q7: Low-stock alert: products with fewer than 40 units ===
SELECT product_id, product_name, stock_qty
FROM products
WHERE stock_qty < 40
ORDER BY stock_qty;

\qecho === Q8: Top 10 products by revenue (delivered orders only) ===
SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;
