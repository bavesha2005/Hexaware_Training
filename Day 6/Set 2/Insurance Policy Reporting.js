db = db.getSiblingDB("InsuranceDB");
db.claims_notes.drop();

db.claims_notes.insertMany([
  { claimId: 1, policyNumber: "MOT-2025-481209", status: "Settled", damageCategory: "Collision", filedDate: ISODate("2026-03-10"), settledDate: ISODate("2026-03-25"), note: "Front bumper damage" },
  { claimId: 2, policyNumber: "HLT-2026-520346", status: "Settled", damageCategory: "Hospitalization", filedDate: ISODate("2026-04-02"), settledDate: ISODate("2026-04-30"), note: "Three day admission" },
  { claimId: 3, policyNumber: "HOM-2024-410592", status: "Settled", damageCategory: "Fire", filedDate: ISODate("2025-06-15"), settledDate: ISODate("2025-07-05"), note: "Kitchen fire" },
  { claimId: 4, policyNumber: "HLT-2026-540167", status: "Open", damageCategory: "Hospitalization", filedDate: ISODate("2026-06-12"), settledDate: null, note: "Documents pending" },
  { claimId: 5, policyNumber: "MOT-2025-490825", status: "Rejected", damageCategory: "Theft", filedDate: ISODate("2026-01-20"), settledDate: null, note: "Policy had expired" },
  { claimId: 6, policyNumber: "HLT-2025-495613", status: "Settled", damageCategory: "Hospitalization", filedDate: ISODate("2026-08-05"), settledDate: ISODate("2026-09-04"), note: "Surgery claim" },
  { claimId: 7, policyNumber: "MOT-2026-545890", status: "Open", damageCategory: "Collision", filedDate: ISODate("2026-09-15"), settledDate: null, note: "Survey scheduled" },
  { claimId: 8, policyNumber: "MOT-2026-530781", status: "Settled", damageCategory: "Windshield", filedDate: ISODate("2026-05-20"), settledDate: ISODate("2026-06-09"), note: "Cracked windshield" }
]);

printjson(db.claims_notes.aggregate([
  { $match: { filedDate: { $gte: ISODate("2025-01-01") } } },
  { $group: { _id: "$status", claims: { $sum: 1 } } },
  { $sort: { claims: -1, _id: 1 } }
]).toArray());

printjson(db.claims_notes.aggregate([
  { $match: { status: "Settled" } },
  { $group: { _id: null, settledClaims: { $sum: 1 }, avgDays: { $avg: { $dateDiff: { startDate: "$filedDate", endDate: "$settledDate", unit: "day" } } } } }
]).toArray());

printjson(db.claims_notes.aggregate([
  { $group: { _id: "$damageCategory", claims: { $sum: 1 } } },
  { $sort: { claims: -1, _id: 1 } },
  { $limit: 3 }
]).toArray());
