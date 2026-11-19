const { MongoClient } = require("mongodb");

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error("Set MONGODB_URI before running this script.");

  const client = new MongoClient(uri);
  await client.connect();

  const db = client.db("day8_airline");
  const seats = db.collection("seats");
  const bookings = db.collection("bookings");

  try {
    await seats.updateOne(
      { flightId: 501, seatNo: "12A" },
      { $setOnInsert: { status: "AVAILABLE" } },
      { upsert: true }
    );

    const session = client.startSession();
    try {
      await session.withTransaction(async () => {
        const seatResult = await seats.updateOne(
          { flightId: 501, seatNo: "12A", status: "AVAILABLE" },
          { $set: { status: "BOOKED" } },
          { session }
        );

        if (seatResult.modifiedCount !== 1) {
          throw new Error("Seat is not available.");
        }

        await bookings.insertOne(
          {
            flightId: 501,
            seatNo: "12A",
            passengerName: "Meera",
            fare: 8500,
            bookedAt: new Date()
          },
          { session }
        );
      });
      console.log("Seat reservation and booking insert committed.");
    } finally {
      await session.endSession();
    }

    console.log("Seat:", await seats.findOne(
      { flightId: 501, seatNo: "12A" },
      { projection: { _id: 0 } }
    ));
    console.log("Bookings:", await bookings.find(
      { flightId: 501, seatNo: "12A" },
      { projection: { _id: 0 } }
    ).toArray());
  } finally {
    await client.close();
  }
}

main().catch(error => {
  console.error("Booking failed:", error.message);
  process.exitCode = 1;
});
