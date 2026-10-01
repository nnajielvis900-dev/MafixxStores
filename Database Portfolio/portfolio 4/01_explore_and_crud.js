// =====================================================================
// Portfolio 4 - Part 1: Explore the document model + CRUD operations
// Run: mongosh "mongodb://localhost:27017/mafixx" --file 01_explore_and_crud.js
// =====================================================================
db = db.getSiblingDB("mafixx");

print("\n=== 1. Collection counts ===");
["products", "customers", "orders", "reviews"].forEach(c => print(c + ": " + db[c].countDocuments()));

print("\n=== 2. One ORDER document: items, payment and delivery are EMBEDDED (no joins needed) ===");
printjson(db.orders.findOne({ status: "Delivered" }));

print("\n=== 3. Flexible schema: phones and fashion items have DIFFERENT attributes in the same collection ===");
printjson(db.products.findOne({ category: "Phones & Tablets" }, { name: 1, attributes: 1, _id: 0 }));
printjson(db.products.findOne({ category: "Fashion" }, { name: 1, attributes: 1, _id: 0 }));

print("\n=== 4. READ: queries on nested fields and arrays ===");
print("Phones with at least 6GB RAM under 400,000:");
printjson(db.products.find({ category: "Phones & Tablets", "attributes.ram_gb": { $gte: 6 }, price: { $lt: 400000 } },
                           { name: 1, price: 1, "attributes.ram_gb": 1, _id: 0 }).limit(5).toArray());
print("Orders for customer 249 (customer is an embedded sub-document):");
printjson(db.orders.find({ "customer.customer_id": 249 }, { order_id: 1, status: 1, total_amount: 1, _id: 0 }).toArray());

print("\n=== 5. CREATE: insert a new product (note: this product has its own extra fields) ===");
db.products.deleteOne({ product_id: 9001 });   // makes the script re-runnable
printjson(db.products.insertOne({
  product_id: 9001, sku: "SKU-NOSQL1", name: "TEST Solar Lantern", category: "Electronics", supplier: "Lagos Gadget Hub",
  price: 15000, stock_qty: 40, attributes: { brand: "Generic", solar: true, battery_hours: 12 }, tags: ["electronics", "solar"],
  created_at: new Date()
}));

print("\n=== 6. UPDATE: sell 3 units (atomic $inc), then add a tag with $push ===");
printjson(db.products.updateOne({ product_id: 9001 }, { $inc: { stock_qty: -3 }, $push: { tags: "bestseller" } }));
printjson(db.products.findOne({ product_id: 9001 }, { name: 1, stock_qty: 1, tags: 1, _id: 0 }));

print("\n=== 7. UPDATE MANY: mark all Pending orders older than 2026-01-01 as Cancelled (dry run count first) ===");
print("Would affect: " + db.orders.countDocuments({ status: "Pending", order_date: { $lt: new Date("2026-01-01") } }) + " orders");
// To actually run it, uncomment the next line:
// printjson(db.orders.updateMany({ status: "Pending", order_date: { $lt: new Date("2026-01-01") } }, { $set: { status: "Cancelled" } }));

print("\n=== 8. DELETE: remove the test product ===");
printjson(db.products.deleteOne({ product_id: 9001 }));
