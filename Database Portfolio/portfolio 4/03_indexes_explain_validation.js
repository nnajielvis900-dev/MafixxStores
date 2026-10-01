// =====================================================================
// Portfolio 4 - Part 3: Indexing with explain(), and schema validation
// Run: mongosh "mongodb://localhost:27017/mafixx" --file 03_indexes_explain_validation.js
// =====================================================================
db = db.getSiblingDB("mafixx");

function summary(label, cursor) {
  const e = cursor.explain("executionStats");
  const s = e.executionStats;
  // find the innermost stage name (COLLSCAN or IXSCAN)
  let stage = e.queryPlanner.winningPlan;
  while (stage.inputStage) stage = stage.inputStage;
  print(label.padEnd(28) + " stage=" + stage.stage + " | docsExamined=" + s.totalDocsExamined +
        " | returned=" + s.nReturned + " | time=" + s.executionTimeMillis + " ms");
}

print("\n=== Start clean: drop our secondary indexes (the automatic _id index always stays) ===");
["orders", "products", "reviews"].forEach(c => db[c].dropIndexes());

print("\n=== BEFORE indexes ===");
summary("orders by customer_id",      db.orders.find({ "customer.customer_id": 249 }));
summary("orders status+date range",   db.orders.find({ status: "Shipped", order_date: { $gte: new Date("2026-08-01") } }));
summary("reviews by product_id",      db.reviews.find({ product_id: 42 }));
summary("products by category",       db.products.find({ category: "Fashion" }));

print("\n=== CREATE indexes ===");
print(db.orders.createIndex({ "customer.customer_id": 1 }));
print(db.orders.createIndex({ status: 1, order_date: -1 }));          // compound: equality field first, then range/sort field
print(db.reviews.createIndex({ product_id: 1 }));
print(db.products.createIndex({ category: 1, price: 1 }));
print(db.products.createIndex({ name: "text" }));                      // full-text search index

print("\n=== AFTER indexes (compare docsExamined and time with BEFORE) ===");
summary("orders by customer_id",      db.orders.find({ "customer.customer_id": 249 }));
summary("orders status+date range",   db.orders.find({ status: "Shipped", order_date: { $gte: new Date("2026-08-01") } }));
summary("reviews by product_id",      db.reviews.find({ product_id: 42 }));
summary("products by category",       db.products.find({ category: "Fashion" }));

print("\n=== Text search using the text index ===");
printjson(db.products.find({ $text: { $search: "samsung phone" } }, { name: 1, price: 1, _id: 0 }).limit(5).toArray());

print("\n=== Indexes on orders ===");
printjson(db.orders.getIndexes());

print("\n=== SCHEMA VALIDATION: MongoDB is flexible, but we can still enforce rules ===");
db.runCommand({
  collMod: "products",
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["product_id", "sku", "name", "category", "price", "stock_qty"],
    properties: {
      product_id: { bsonType: ["int", "long", "double"] },
      sku:        { bsonType: "string" },
      name:       { bsonType: "string" },
      price:      { bsonType: ["int", "long", "double", "decimal"], minimum: 1, description: "must be a positive number" },
      stock_qty:  { bsonType: ["int", "long", "double"], minimum: 0, description: "cannot be negative" }
    } } },
  validationLevel: "moderate", validationAction: "error"
});
print("Validator installed. Now try to insert an INVALID product (negative price, missing fields): expect a 'Document failed validation' error:");
try {
  db.products.insertOne({ product_id: 9002, name: "Bad product", price: -50 });
} catch (err) {
  print("ERROR (expected): " + err.message);
}
