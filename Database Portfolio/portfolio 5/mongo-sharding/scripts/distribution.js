// Run on mongos after importing orders.json: shows how documents were split between shards.
db = db.getSiblingDB("mafixx");
print("Total orders via mongos: " + db.orders.countDocuments());
db.orders.getShardDistribution();
print("\n--- Targeted query (shard key in filter) -> only ONE shard is contacted ---");
const t = db.orders.find({ "customer.customer_id": 249 }).explain("queryPlanner").queryPlanner.winningPlan;
print("Stage: " + t.stage + " | shards: " + (t.shards || []).map(s => s.shardName).join(", "));
print("\n--- Scatter-gather query (no shard key) -> ALL shards are contacted ---");
const u = db.orders.find({ status: "Shipped" }).explain("queryPlanner").queryPlanner.winningPlan;
print("Stage: " + u.stage + " | shards: " + (u.shards || []).map(s => s.shardName).join(", "));
sh.status();
