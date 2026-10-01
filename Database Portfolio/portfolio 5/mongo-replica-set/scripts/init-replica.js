// Turns the three separate mongod servers into ONE replica set named rs0.
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 },   // higher priority = preferred primary
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
});
print("Replica set initiated. Wait ~15 seconds, then run status.js");
