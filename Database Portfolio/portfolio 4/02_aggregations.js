// =====================================================================
// Portfolio 4 - Part 2: Aggregation pipelines (MongoDB's equivalent of GROUP BY / JOIN)
// Run: mongosh "mongodb://localhost:27017/mafixx" --file 02_aggregations.js
// =====================================================================
db = db.getSiblingDB("mafixx");

print("\n=== A1. Orders and revenue per status ===");
printjson(db.orders.aggregate([
  { $group: { _id: "$status", orders: { $sum: 1 }, revenue: { $sum: "$total_amount" } } },
  { $sort: { orders: -1 } }
]).toArray());

print("\n=== A2. Top 5 products by revenue: $unwind flattens the embedded items array ===");
printjson(db.orders.aggregate([
  { $match: { status: "Delivered" } },
  { $unwind: "$items" },
  { $group: { _id: "$items.name", units: { $sum: "$items.quantity" },
              revenue: { $sum: { $multiply: ["$items.quantity", "$items.unit_price"] } } } },
  { $sort: { revenue: -1 } },
  { $limit: 5 }
]).toArray());

print("\n=== A3. Monthly revenue in 2025 ===");
printjson(db.orders.aggregate([
  { $match: { status: { $ne: "Cancelled" }, order_date: { $gte: new Date("2025-01-01"), $lt: new Date("2026-01-01") } } },
  { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$order_date" } }, revenue: { $sum: "$total_amount" }, orders: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).toArray());

print("\n=== A4. $lookup (like a SQL JOIN): revenue per CATEGORY, joining order items to products ===");
printjson(db.orders.aggregate([
  { $match: { status: "Delivered" } },
  { $unwind: "$items" },
  { $lookup: { from: "products", localField: "items.product_id", foreignField: "product_id", as: "prod" } },
  { $unwind: "$prod" },
  { $group: { _id: "$prod.category", revenue: { $sum: { $multiply: ["$items.quantity", "$items.unit_price"] } } } },
  { $sort: { revenue: -1 } }
]).toArray());

print("\n=== A5. Average rating per product (reviews collection), best 5 with at least 5 reviews ===");
printjson(db.reviews.aggregate([
  { $group: { _id: "$product_id", avg_rating: { $avg: "$rating" }, reviews: { $sum: 1 } } },
  { $match: { reviews: { $gte: 5 } } },
  { $sort: { avg_rating: -1, reviews: -1 } },
  { $limit: 5 },
  { $lookup: { from: "products", localField: "_id", foreignField: "product_id", as: "p" } },
  { $project: { _id: 0, product: { $arrayElemAt: ["$p.name", 0] }, avg_rating: { $round: ["$avg_rating", 2] }, reviews: 1 } }
]).toArray());

print("\n=== A6. Customer feed: latest 3 orders of customer 249 with delivery state ===");
printjson(db.orders.aggregate([
  { $match: { "customer.customer_id": 249 } },
  { $sort: { order_date: -1 } },
  { $limit: 3 },
  { $project: { _id: 0, order_id: 1, order_date: 1, status: 1, total_amount: 1, delivery_status: "$delivery.status" } }
]).toArray());
