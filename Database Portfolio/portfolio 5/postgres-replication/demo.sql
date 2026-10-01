-- Commands for the replication demo. Run them with:
--   docker exec -it pg-primary psql -U postgres -d mafixx     (PRIMARY)
--   docker exec -it pg-replica psql -U postgres -d mafixx     (REPLICA)
-- See the guide "Portfolio 5 steps" for the exact order.

-- ===== ON THE PRIMARY =====
CREATE TABLE IF NOT EXISTS orders_demo (order_id SERIAL PRIMARY KEY, customer_id INT, total NUMERIC, created_at TIMESTAMP DEFAULT now());
INSERT INTO orders_demo (customer_id, total) VALUES (1, 150000), (2, 42000), (3, 89500);
SELECT pg_is_in_recovery() AS is_replica;                                   -- false on primary
SELECT client_addr, state, sync_state, replay_lag FROM pg_stat_replication; -- shows the replica connected ("streaming")

-- ===== ON THE REPLICA =====
SELECT pg_is_in_recovery() AS is_replica;                                   -- true on replica
SELECT * FROM orders_demo;                                                   -- the 3 rows appeared automatically
INSERT INTO orders_demo (customer_id, total) VALUES (9, 1);                  -- ERROR: cannot execute INSERT in a read-only transaction
SELECT now() - pg_last_xact_replay_timestamp() AS replication_delay;

-- ===== BACK ON THE PRIMARY: a new write reaches the replica within milliseconds =====
INSERT INTO orders_demo (customer_id, total) VALUES (4, 7000);
-- (then SELECT * FROM orders_demo; on the replica again)
