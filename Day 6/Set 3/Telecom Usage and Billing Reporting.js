db = db.getSiblingDB("TelecomDB");
db.usage_events.drop();

db.usage_events.insertMany([
  { subscriberId: 1, cellTower: "T-101", startTime: ISODate("2026-11-17T08:05:00Z"), type: "call", durationSec: 300, dataMB: 0 },
  { subscriberId: 1, cellTower: "T-101", startTime: ISODate("2026-11-17T08:40:00Z"), type: "data", durationSec: 1200, dataMB: 350 },
  { subscriberId: 2, cellTower: "T-102", startTime: ISODate("2026-11-17T08:55:00Z"), type: "call", durationSec: 120, dataMB: 0 },
  { subscriberId: 3, cellTower: "T-101", startTime: ISODate("2026-11-17T09:10:00Z"), type: "data", durationSec: 1800, dataMB: 900 },
  { subscriberId: 3, cellTower: "T-103", startTime: ISODate("2026-11-17T09:30:00Z"), type: "call", durationSec: 600, dataMB: 0 },
  { subscriberId: 4, cellTower: "T-101", startTime: ISODate("2026-11-17T09:45:00Z"), type: "data", durationSec: 900, dataMB: 420 },
  { subscriberId: 5, cellTower: "T-102", startTime: ISODate("2026-11-17T10:15:00Z"), type: "call", durationSec: 240, dataMB: 0 },
  { subscriberId: 6, cellTower: "T-101", startTime: ISODate("2026-11-17T10:20:00Z"), type: "data", durationSec: 2400, dataMB: 1100 },
  { subscriberId: 6, cellTower: "T-101", startTime: ISODate("2026-11-17T10:50:00Z"), type: "call", durationSec: 480, dataMB: 0 },
  { subscriberId: 7, cellTower: "T-103", startTime: ISODate("2026-11-17T14:05:00Z"), type: "call", durationSec: 60, dataMB: 0 },
  { subscriberId: 8, cellTower: "T-102", startTime: ISODate("2026-11-17T14:30:00Z"), type: "data", durationSec: 3000, dataMB: 1500 },
  { subscriberId: 8, cellTower: "T-101", startTime: ISODate("2026-11-17T21:10:00Z"), type: "data", durationSec: 1500, dataMB: 700 },
  { subscriberId: 9, cellTower: "T-103", startTime: ISODate("2026-11-17T21:25:00Z"), type: "call", durationSec: 180, dataMB: 0 },
  { subscriberId: 2, cellTower: "T-102", startTime: ISODate("2026-11-17T21:40:00Z"), type: "data", durationSec: 600, dataMB: 150 }
]);

printjson(db.usage_events.aggregate([
  { $match: { startTime: { $gte: ISODate("2026-11-17"), $lt: ISODate("2026-11-18") } } },
  { $group: { _id: { $hour: "$startTime" }, events: { $sum: 1 }, dataMB: { $sum: "$dataMB" } } },
  { $sort: { _id: 1 } }
]).toArray());

printjson(db.usage_events.aggregate([
  { $match: { durationSec: { $gt: 0 } } },
  { $group: { _id: "$type", sessions: { $sum: 1 }, avgSec: { $avg: "$durationSec" } } },
  { $sort: { avgSec: -1 } },
  { $set: { avgSec: { $round: ["$avgSec", 2] } } }
]).toArray());

printjson(db.usage_events.aggregate([
  { $match: { startTime: { $gte: ISODate("2026-11-17"), $lt: ISODate("2026-11-18") } } },
  { $group: { _id: "$cellTower", events: { $sum: 1 }, dataMB: { $sum: "$dataMB" } } },
  { $sort: { events: -1 } },
  { $limit: 1 }
]).toArray());
