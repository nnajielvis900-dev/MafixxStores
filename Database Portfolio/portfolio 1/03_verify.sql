-- =====================================================================
-- Verification: proves the import worked and the data is consistent.
-- Expected row counts: categories 8, suppliers 15, customers 2000, products 200,
-- orders 50000, order_items 109828, payments 50000, deliveries 35018.
-- =====================================================================
\qecho === Row counts ===
SELECT 'categories' AS table_name, count(*) FROM categories UNION ALL
SELECT 'suppliers',   count(*) FROM suppliers   UNION ALL
SELECT 'customers',   count(*) FROM customers   UNION ALL
SELECT 'products',    count(*) FROM products    UNION ALL
SELECT 'orders',      count(*) FROM orders      UNION ALL
SELECT 'order_items', count(*) FROM order_items UNION ALL
SELECT 'payments',    count(*) FROM payments    UNION ALL
SELECT 'deliveries',  count(*) FROM deliveries;

\qecho === Integrity check: order totals must equal the sum of their items (expect 0 rows mismatching) ===
SELECT count(*) AS mismatching_orders
FROM orders o
JOIN (SELECT order_id, SUM(quantity*unit_price) AS t FROM order_items GROUP BY order_id) x USING (order_id)
WHERE o.total_amount <> x.t;

\qecho === Constraint demo: each of these should FAIL (run them one at a time and screenshot the errors) ===
-- INSERT INTO products (sku, product_name, category_id, supplier_id, unit_price, stock_qty) VALUES ('SKU-BAD','Bad',1,1,-5,10);      -- CHECK unit_price > 0
-- INSERT INTO customers (full_name, email, city, state) VALUES ('Dup','chinedu.okafor-x@example.com','Lagos','Lagos'), ('Dup2','chinedu.okafor-x@example.com','Lagos','Lagos'); -- UNIQUE email
-- INSERT INTO orders (customer_id, total_amount) VALUES (999999, 100);                                                                -- FOREIGN KEY
-- UPDATE products SET stock_qty = -1 WHERE product_id = 1;                                                                            -- CHECK stock_qty >= 0
