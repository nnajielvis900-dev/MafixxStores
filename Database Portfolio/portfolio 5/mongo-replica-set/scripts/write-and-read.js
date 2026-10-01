// Run on the PRIMARY (mongo1): write with majority write concern, then count documents.
db = db.getSiblingDB("mafixx");
const r = db.getCollection("orders_demo").insertMany(
  [ { order_id: 1, total: 150000 }, { order_id: 2, total: 42000 }, { order_id: 3, total: 89500 } ],
  { writeConcern: { w: "majority", wtimeout: 5000 } }   // acknowledged only after a MAJORITY (2 of 3) nodes have it
);
print("Inserted (acknowledged by majority): " + Object.keys(r.insertedIds).length);
print("Documents in orders_demo: " + db.orders_demo.countDocuments());
