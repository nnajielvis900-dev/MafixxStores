// Run on mongos: register the shards and shard the orders collection BEFORE loading data.
sh.addShard("shard1rs/shard1:27017");
sh.addShard("shard2rs/shard2:27017");
sh.enableSharding("mafixx");
// Shard key: customer.customer_id, HASHED -> orders spread evenly; a customer's own orders
// are found on ONE shard (targeted query).
sh.shardCollection("mafixx.orders", { "customer.customer_id": "hashed" });
print("Cluster ready. Now import the data (see the Portfolio 5 guide), then run distribution.js");
