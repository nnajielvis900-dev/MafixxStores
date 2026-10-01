-- =====================================================================
-- Loads the CSV files from the ./data folder into the tables.
-- IMPORTANT: run this from INSIDE this folder so that "data/..." paths work.
--   cd portfolio-1-database-design
--   psql -U postgres -d mafixx -f 02_import_data.sql
-- (\copy reads files on YOUR computer, so no special permissions are needed.)
-- Order matters: parent tables first, child tables after (foreign keys).
-- =====================================================================
\copy categories  (category_id, category_name)                                   FROM 'data/categories.csv'  WITH (FORMAT csv, HEADER true)
\copy suppliers   (supplier_id, supplier_name, city)                             FROM 'data/suppliers.csv'   WITH (FORMAT csv, HEADER true)
\copy customers   (customer_id, full_name, email, phone, city, state, created_at) FROM 'data/customers.csv'  WITH (FORMAT csv, HEADER true)
\copy products    (product_id, sku, product_name, category_id, supplier_id, unit_price, stock_qty, created_at) FROM 'data/products.csv' WITH (FORMAT csv, HEADER true)
\copy orders      (order_id, customer_id, order_date, status, total_amount)      FROM 'data/orders.csv'      WITH (FORMAT csv, HEADER true)
\copy order_items (order_id, product_id, quantity, unit_price)                   FROM 'data/order_items.csv' WITH (FORMAT csv, HEADER true)
\copy payments    (payment_id, order_id, amount, method, payment_status, paid_at) FROM 'data/payments.csv'   WITH (FORMAT csv, HEADER true)
\copy deliveries  (delivery_id, order_id, courier, delivery_status, shipped_at, delivered_at, delivery_city) FROM 'data/deliveries.csv' WITH (FORMAT csv, HEADER true)

-- We inserted explicit IDs, so move each identity counter past the highest ID.
SELECT setval(pg_get_serial_sequence('customers','customer_id'),  (SELECT max(customer_id) FROM customers));
SELECT setval(pg_get_serial_sequence('categories','category_id'), (SELECT max(category_id) FROM categories));
SELECT setval(pg_get_serial_sequence('suppliers','supplier_id'),  (SELECT max(supplier_id) FROM suppliers));
SELECT setval(pg_get_serial_sequence('products','product_id'),    (SELECT max(product_id) FROM products));
SELECT setval(pg_get_serial_sequence('orders','order_id'),        (SELECT max(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('payments','payment_id'),    (SELECT max(payment_id) FROM payments));
SELECT setval(pg_get_serial_sequence('deliveries','delivery_id'), (SELECT max(delivery_id) FROM deliveries));

ANALYZE;   -- refresh planner statistics (important for Portfolio 2)
