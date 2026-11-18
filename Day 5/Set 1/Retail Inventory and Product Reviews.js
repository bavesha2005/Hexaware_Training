db = db.getSiblingDB("RetailInventoryDB");
db.reviews.drop();

db.createCollection("reviews", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["sku", "customerName", "rating", "comment", "reviewedAt"],
      properties: {
        sku: { bsonType: "string" },
        customerName: { bsonType: "string" },
        rating: { bsonType: "number", minimum: 1, maximum: 5 },
        comment: { bsonType: "string" },
        reviewedAt: { bsonType: "date" },
        helpfulVotes: { bsonType: "number", minimum: 0 }
      }
    }
  }
});

db.reviews.insertMany([
  { sku: "EL-1001", customerName: "Arun", rating: 5, comment: "Smooth and quiet", reviewedAt: ISODate("2026-10-02"), helpfulVotes: 4 },
  { sku: "EL-1001", customerName: "Divya", rating: 4, comment: "Good battery life", reviewedAt: ISODate("2026-10-05"), helpfulVotes: 1 },
  { sku: "EL-1001", customerName: "Karthik", rating: 2, comment: "Scroll wheel is loose", reviewedAt: ISODate("2026-10-09"), helpfulVotes: 0 },
  { sku: "EL-1002", customerName: "Meena", rating: 4, comment: "Works with my laptop", reviewedAt: ISODate("2026-10-11"), helpfulVotes: 2 },
  { sku: "HA-2001", customerName: "Rahul", rating: 5, comment: "Boils fast", reviewedAt: ISODate("2026-10-14"), helpfulVotes: 3 },
  { sku: "SP-5001", customerName: "Sneha", rating: 3, comment: "A bit slippery", reviewedAt: ISODate("2026-10-17"), helpfulVotes: 0 },
  { sku: "KI-6001", customerName: "Vikram", rating: 4, comment: "Nothing sticks", reviewedAt: ISODate("2026-10-20"), helpfulVotes: 1 },
  { sku: "PC-7001", customerName: "Priya", rating: 5, comment: "Dentist approved", reviewedAt: ISODate("2026-10-23"), helpfulVotes: 5 },
  { sku: "TY-8001", customerName: "Suresh", rating: 4, comment: "My kids love it", reviewedAt: ISODate("2026-10-26"), helpfulVotes: 2 },
  { sku: "AC-9001", customerName: "Lakshmi", rating: 1, comment: "Stitching came apart", reviewedAt: ISODate("2026-10-28"), helpfulVotes: 0 }
]);

printjson(db.reviews.find({ sku: "EL-1001", rating: { $gte: 4 } }, { _id: 0, customerName: 1, rating: 1 }).toArray());

db.reviews.updateOne(
  { sku: "EL-1001", customerName: "Karthik" },
  { $set: { rating: 3, comment: "Replaced under warranty, now fine" }, $inc: { helpfulVotes: 1 } }
);

db.reviews.deleteOne({ sku: "AC-9001", customerName: "Lakshmi" });

printjson(db.reviews.countDocuments());
