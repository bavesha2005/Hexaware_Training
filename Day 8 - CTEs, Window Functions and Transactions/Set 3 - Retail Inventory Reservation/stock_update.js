const { MongoClient } = require("mongodb");

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error("Set MONGODB_URI before running this script.");

  const client = new MongoClient(uri);
  await client.connect();

  const db = client.db("day8_retail");
  const inventory = db.collection("inventory");

  try {
    await inventory.updateOne(
      { productId: 1 },
      { $setOnInsert: { productName: "Wireless Mouse", stock: 20 } },
      { upsert: true }
    );

    const requestedQuantity = 3;
    const result = await inventory.updateOne(
      {
        productId: 1,
        stock: { $gte: requestedQuantity }
      },
      {
        $inc: { stock: -requestedQuantity }
      }
    );

    if (result.modifiedCount !== 1) {
      throw new Error("Product not found or insufficient stock.");
    }

    console.log("Stock reservation successful.");
    console.log("Inventory:", await inventory.findOne(
      { productId: 1 },
      { projection: { _id: 0 } }
    ));
  } finally {
    await client.close();
  }
}

main().catch(error => {
  console.error("Stock update failed:", error.message);
  process.exitCode = 1;
});
