// Run on a SECONDARY (mongo2): shows replicated data and that secondaries refuse writes.
db = db.getSiblingDB("mafixx");
db.getMongo().setReadPref("secondary");
print("Documents visible on this secondary: " + db.orders_demo.countDocuments());
try {
  db.orders_demo.insertOne({ order_id: 99, total: 1 });
  print("Write succeeded (unexpected for a secondary)");
} catch (e) {
  print("Write rejected (expected): " + e.message);
}
