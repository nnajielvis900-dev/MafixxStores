-- =====================================================================
-- Demo 1: COMMIT and ROLLBACK (Atomicity + Durability)
-- Run:  psql -U postgres -d mafixx -f 01_commit_rollback.sql -o output_01.txt
-- Re-running resets the test stock first, so you can repeat it safely.
-- =====================================================================
UPDATE products SET stock_qty = 5 WHERE product_id = 9001;
\qecho
\qecho ===== A. SUCCESSFUL TRANSACTION -> COMMIT: customer 1 buys 2 x product 9001 =====
\qecho -- Stock BEFORE:
SELECT product_id, stock_qty FROM products WHERE product_id = 9001;

BEGIN;
SELECT place_order(1, 9001, 2) AS new_order_id;
COMMIT;

\qecho -- Stock AFTER COMMIT (should be 3), and the order + log rows that were saved:
SELECT product_id, stock_qty FROM products WHERE product_id = 9001;
SELECT o.order_id, o.customer_id, o.status, o.total_amount FROM orders o ORDER BY order_id DESC LIMIT 1;
SELECT * FROM stock_log ORDER BY log_id DESC LIMIT 1;

\qecho
\qecho ===== B. FAILING TRANSACTION -> ROLLBACK: customer 1 tries to buy 10 (only 3 in stock) =====
\set ON_ERROR_STOP off
BEGIN;
SELECT place_order(1, 9001, 10);
\qecho -- (The line above fails with: Insufficient stock... The transaction is now aborted.)
ROLLBACK;
\qecho -- Stock is unchanged (still 3) and no new order was created:
SELECT product_id, stock_qty FROM products WHERE product_id = 9001;
SELECT max(order_id) AS latest_order_id FROM orders;

\qecho
\qecho ===== C. MANUAL ROLLBACK: change data, look at it, then undo it =====
BEGIN;
UPDATE products SET stock_qty = 0 WHERE product_id = 9002;
\qecho -- Inside the transaction (stock shows 0):
SELECT product_id, stock_qty FROM products WHERE product_id = 9002;
ROLLBACK;
\qecho -- After ROLLBACK (back to 10):
SELECT product_id, stock_qty FROM products WHERE product_id = 9002;

\qecho
\qecho ===== D. SAVEPOINT: undo only part of a transaction =====
BEGIN;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 9002;      -- step 1 (kept)
SAVEPOINT after_step1;
UPDATE products SET stock_qty = stock_qty - 5 WHERE product_id = 9002;      -- step 2 (will be undone)
ROLLBACK TO SAVEPOINT after_step1;
COMMIT;
\qecho -- Expected: 9 (only step 1 survived)
SELECT product_id, stock_qty FROM products WHERE product_id = 9002;

\qecho
\qecho ===== E. CONSTRAINT protects data integrity: negative stock is rejected =====
UPDATE products SET stock_qty = -1 WHERE product_id = 9002;
\qecho -- (error above is expected: violates check constraint products_stock_qty_check)
