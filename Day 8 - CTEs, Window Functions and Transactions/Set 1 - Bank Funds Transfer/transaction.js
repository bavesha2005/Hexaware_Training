const { MongoClient } = require("mongodb");

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error("Set MONGODB_URI before running this script.");

  const client = new MongoClient(uri);
  await client.connect();

  const db = client.db("day8_bank");
  const accounts = db.collection("accounts");
  const ledger = db.collection("transactions");

  try {
    await accounts.updateOne(
      { accountId: 101 },
      { $setOnInsert: { holder: "Asha", balance: 10000, status: "ACTIVE" } },
      { upsert: true }
    );
    await accounts.updateOne(
      { accountId: 102 },
      { $setOnInsert: { holder: "Ravi", balance: 5000, status: "ACTIVE" } },
      { upsert: true }
    );

    const session = client.startSession();
    try {
      await session.withTransaction(async () => {
        const amount = 1500;

        const debit = await accounts.updateOne(
          { accountId: 101, status: "ACTIVE", balance: { $gte: amount } },
          { $inc: { balance: -amount } },
          { session }
        );
        if (debit.modifiedCount !== 1) {
          throw new Error("Source account missing, inactive, or insufficient funds.");
        }

        const credit = await accounts.updateOne(
          { accountId: 102, status: "ACTIVE" },
          { $inc: { balance: amount } },
          { session }
        );
        if (credit.modifiedCount !== 1) {
          throw new Error("Destination account missing or inactive.");
        }

        await ledger.insertOne(
          {
            fromAccountId: 101,
            toAccountId: 102,
            amount,
            type: "TRANSFER",
            createdAt: new Date()
          },
          { session }
        );
      });
      console.log("Transfer committed.");
    } finally {
      await session.endSession();
    }

    console.log("Accounts:", await accounts.find(
      { accountId: { $in: [101, 102] } },
      { projection: { _id: 0 } }
    ).sort({ accountId: 1 }).toArray());
  } finally {
    await client.close();
  }
}

main().catch(error => {
  console.error("Transfer failed:", error.message);
  process.exitCode = 1;
});
