// Prints which member is PRIMARY / SECONDARY. Run against any node.
const s = rs.status();
print("Replica set: " + s.set);
s.members.forEach(m => print(m.name.padEnd(14) + " " + m.stateStr.padEnd(10) + " health=" + m.health));
