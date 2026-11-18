use("BankBranchDB");

db.customer_activity_logs.drop();

db.createCollection("customer_activity_logs", {
  capped: true,
  size: 1048576,
  max: 5000,
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["customerId", "accountNumber", "eventType", "eventTime", "channel"],
      properties: {
        customerId:    { bsonType: ["int", "long", "double"] },
        accountNumber: { bsonType: "string" },
        eventType: {
          enum: ["LOGIN", "LOGOUT", "LOGIN_FAILED", "BALANCE_CHECK", "FUND_TRANSFER", "PASSWORD_CHANGE"]
        },
        eventTime:     { bsonType: "date" },
        channel:       { enum: ["MOBILE", "WEB", "ATM"] }
      }
    }
  },
  validationAction: "error"
});

print("Is capped? " + db.customer_activity_logs.isCapped());

db.customer_activity_logs.createIndex({ customerId: 1, eventType: 1, eventTime: -1 });

db.customer_activity_logs.insertMany([
  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-02T03:35:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "BALANCE_CHECK",
    eventTime: ISODate("2026-11-02T03:37:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS", details: { balanceShown: 45200.50 } },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGOUT",
    eventTime: ISODate("2026-11-02T03:42:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS", details: { sessionMinutes: 7 } },

  { customerId: 2, accountNumber: "CA2000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-03T04:45:00Z"), channel: "WEB", ipAddress: "117.200.14.77",
    device: { type: "Desktop", browser: "Chrome" }, location: { city: "Coimbatore", country: "IN" },
    status: "SUCCESS" },

  { customerId: 3, accountNumber: "SB1000003", eventType: "LOGIN",
    eventTime: ISODate("2026-11-04T06:00:00Z"), channel: "MOBILE", ipAddress: "49.37.201.5",
    device: { type: "iOS", model: "iPhone 14" }, location: { city: "Bengaluru", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN_FAILED",
    eventTime: ISODate("2026-11-05T14:20:00Z"), channel: "WEB", ipAddress: "103.21.58.44",
    device: { type: "Desktop", browser: "Firefox" }, location: { city: "Chennai", country: "IN" },
    status: "FAILED", details: { reason: "Incorrect password" } },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-05T14:22:00Z"), channel: "WEB", ipAddress: "103.21.58.44",
    device: { type: "Desktop", browser: "Firefox" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 2, accountNumber: "CA2000001", eventType: "FUND_TRANSFER",
    eventTime: ISODate("2026-11-06T05:10:00Z"), channel: "WEB", ipAddress: "117.200.14.77",
    device: { type: "Desktop", browser: "Chrome" }, location: { city: "Coimbatore", country: "IN" },
    status: "SUCCESS", details: { toAccount: "SB1000004", amount: 15000.00 } },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-09T03:50:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 4, accountNumber: "SB1000004", eventType: "LOGIN",
    eventTime: ISODate("2026-11-10T08:15:00Z"), channel: "WEB", ipAddress: "122.164.33.9",
    device: { type: "Desktop", browser: "Edge" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-12T13:05:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "FUND_TRANSFER",
    eventTime: ISODate("2026-11-12T13:09:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS", details: { toAccount: "CA2000001", amount: 5000.00 } },

  { customerId: 3, accountNumber: "SB1000003", eventType: "LOGIN_FAILED",
    eventTime: ISODate("2026-11-12T15:30:00Z"), channel: "MOBILE", ipAddress: "49.37.201.5",
    device: { type: "iOS", model: "iPhone 14" }, location: { city: "Bengaluru", country: "IN" },
    status: "FAILED", details: { reason: "Incorrect PIN" } },

  { customerId: 2, accountNumber: "CA2000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-14T04:00:00Z"), channel: "WEB", ipAddress: "117.200.14.77",
    device: { type: "Desktop", browser: "Chrome" }, location: { city: "Coimbatore", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-15T05:30:00Z"), channel: "WEB", ipAddress: "103.21.58.44",
    device: { type: "Desktop", browser: "Firefox" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 1, accountNumber: "SB1000001", eventType: "PASSWORD_CHANGE",
    eventTime: ISODate("2026-11-15T05:40:00Z"), channel: "WEB", ipAddress: "103.21.58.44",
    device: { type: "Desktop", browser: "Firefox" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 5, accountNumber: "SB1000005", eventType: "LOGIN",
    eventTime: ISODate("2026-11-15T09:00:00Z"), channel: "MOBILE", ipAddress: "157.49.12.80",
    device: { type: "Android", model: "Galaxy S23" }, location: { city: "Madurai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 4, accountNumber: "SB1000004", eventType: "FUND_TRANSFER",
    eventTime: ISODate("2026-11-16T07:25:00Z"), channel: "WEB", ipAddress: "122.164.33.9",
    device: { type: "Desktop", browser: "Edge" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS", details: { toAccount: "SB1000005", amount: 2500.00 } },

  { customerId: 1, accountNumber: "SB1000001", eventType: "LOGIN",
    eventTime: ISODate("2026-11-17T03:40:00Z"), channel: "MOBILE", ipAddress: "103.21.58.10",
    device: { type: "Android", model: "Pixel 7" }, location: { city: "Chennai", country: "IN" },
    status: "SUCCESS" },

  { customerId: 2, accountNumber: "CA2000001", eventType: "LOGOUT",
    eventTime: ISODate("2026-11-17T04:20:00Z"), channel: "WEB", ipAddress: "117.200.14.77",
    device: { type: "Desktop", browser: "Chrome" }, location: { city: "Coimbatore", country: "IN" },
    status: "SUCCESS", details: { sessionMinutes: 14 } }
]);

print("Documents inserted: " + db.customer_activity_logs.countDocuments());

print("\n--- Last 5 logins of customer 1 (sorted by eventTime) ---");
db.customer_activity_logs
  .find({ customerId: 1, eventType: "LOGIN" },
        { _id: 0, customerId: 1, eventType: 1, eventTime: 1, channel: 1, ipAddress: 1 })
  .sort({ eventTime: -1 })
  .limit(5)
  .forEach(doc => printjson(doc));

print("\n--- Last 5 logins of customer 1 (reverse natural order) ---");
db.customer_activity_logs
  .find({ customerId: 1, eventType: "LOGIN" },
        { _id: 0, customerId: 1, eventType: 1, eventTime: 1, channel: 1 })
  .sort({ $natural: -1 })
  .limit(5)
  .forEach(doc => printjson(doc));

print("\n--- Events per customer ---");
db.customer_activity_logs.aggregate([
  { $group: { _id: "$customerId", totalEvents: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).forEach(doc => printjson(doc));

print("\n--- Failed login attempts ---");
db.customer_activity_logs
  .find({ eventType: "LOGIN_FAILED" }, { _id: 0, customerId: 1, eventTime: 1, "details.reason": 1 })
  .forEach(doc => printjson(doc));

printjson({
  capped:   db.customer_activity_logs.isCapped(),
  count:    db.customer_activity_logs.countDocuments(),
  maxDocs:  db.customer_activity_logs.stats().max,
  maxBytes: db.customer_activity_logs.stats().maxSize
});
