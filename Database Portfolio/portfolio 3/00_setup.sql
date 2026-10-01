-- =====================================================================
-- Portfolio 3 setup: test products + a safe "place_order" function.
-- Run once:  psql -U postgres -d mafixx -f 00_setup.sql
-- =====================================================================
-- Test products with tiny stock so we can demonstrate conflicts easily.
-- (Explicit IDs 9001-9002 so they never clash with the 200 real products.)
INSERT INTO products (product_id, sku, product_name, category_id, supplier_id, unit_price, stock_qty)
VALUES (9001, 'SKU-TEST1', 'TEST Limited Edition Phone', 1, 1, 100000, 5),
       (9002, 'SKU-TEST2', 'TEST Power Bank',            3, 1,  20000, 10)
ON CONFLICT (product_id) DO UPDATE SET stock_qty = EXCLUDED.stock_qty;

-- place_order: one business operation made of several steps that MUST succeed or fail together (atomicity).
CREATE OR REPLACE FUNCTION place_order(p_customer_id INT, p_product_id INT, p_qty INT)
RETURNS INT AS $$
DECLARE
    v_stock INT; v_price NUMERIC; v_order_id INT;
BEGIN
    -- FOR UPDATE locks the product row so nobody else can change its stock until we finish
    SELECT stock_qty, unit_price INTO v_stock, v_price
    FROM products WHERE product_id = p_product_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product % does not exist', p_product_id;
    END IF;
    IF v_stock < p_qty THEN
        RAISE EXCEPTION 'Insufficient stock for product %: requested %, available %', p_product_id, p_qty, v_stock;
    END IF;

    INSERT INTO orders (customer_id, order_date, status, total_amount)
    VALUES (p_customer_id, now(), 'Pending', v_price * p_qty)
    RETURNING order_id INTO v_order_id;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_qty, v_price);

    UPDATE products SET stock_qty = stock_qty - p_qty WHERE product_id = p_product_id;

    INSERT INTO stock_log (product_id, change_qty, reason)
    VALUES (p_product_id, -p_qty, 'Order ' || v_order_id);

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

SELECT product_id, product_name, stock_qty FROM products WHERE product_id IN (9001, 9002);
