-- =====================================================================
-- Part E: Advanced SQL features (supports the "advanced concepts" marks)
-- =====================================================================
\qecho === View: customer lifetime value (reusable business logic) ===
CREATE OR REPLACE VIEW v_customer_value AS
SELECT c.customer_id, c.full_name, c.city,
       COUNT(o.order_id)   AS orders_placed,
       COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status <> 'Cancelled'
GROUP BY c.customer_id, c.full_name, c.city;

SELECT * FROM v_customer_value ORDER BY total_spent DESC LIMIT 10;

\qecho === Window function: rank products by revenue WITHIN each category (top 3 each) ===
WITH product_revenue AS (
    SELECT p.product_id, p.product_name, cat.category_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p    ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    JOIN orders o      ON o.order_id = oi.order_id AND o.status = 'Delivered'
    GROUP BY p.product_id, p.product_name, cat.category_name
)
SELECT * FROM (
    SELECT category_name, product_name, revenue,
           RANK() OVER (PARTITION BY category_name ORDER BY revenue DESC) AS rank_in_category
    FROM product_revenue
) ranked
WHERE rank_in_category <= 3
ORDER BY category_name, rank_in_category;

\qecho === Running total of monthly revenue (window function over the materialized view) ===
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM mv_monthly_revenue
ORDER BY month;
