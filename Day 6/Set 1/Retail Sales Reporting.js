db = db.getSiblingDB("RetailSalesDB");
db.orders.drop();

db.orders.insertMany([
  { _id: 1, customer: "Arun", city: "Chennai", orderDate: ISODate("2026-01-05"), total: 2000, items: [{ product: "Wireless Mouse", quantity: 2, price: 500 }, { product: "Notebook Pack", quantity: 5, price: 200 }] },
  { _id: 2, customer: "Arun", city: "Chennai", orderDate: ISODate("2026-01-20"), total: 1200, items: [{ product: "USB-C Hub", quantity: 1, price: 1200 }] },
  { _id: 3, customer: "Arun", city: "Chennai", orderDate: ISODate("2026-02-10"), total: 4000, items: [{ product: "Office Chair", quantity: 1, price: 4000 }] },
  { _id: 4, customer: "Arun", city: "Chennai", orderDate: ISODate("2026-02-25"), total: 1600, items: [{ product: "Yoga Mat", quantity: 2, price: 800 }] },
  { _id: 5, customer: "Divya", city: "Chennai", orderDate: ISODate("2026-01-20"), total: 1500, items: [{ product: "Electric Kettle", quantity: 1, price: 1500 }] },
  { _id: 6, customer: "Divya", city: "Chennai", orderDate: ISODate("2026-02-14"), total: 1500, items: [{ product: "Wireless Mouse", quantity: 3, price: 500 }] },
  { _id: 7, customer: "Karthik", city: "Coimbatore", orderDate: ISODate("2026-02-25"), total: 8000, items: [{ product: "Office Chair", quantity: 2, price: 4000 }] },
  { _id: 8, customer: "Karthik", city: "Coimbatore", orderDate: ISODate("2026-03-03"), total: 4400, items: [{ product: "USB-C Hub", quantity: 2, price: 1200 }, { product: "Notebook Pack", quantity: 10, price: 200 }] },
  { _id: 9, customer: "Meena", city: "Bengaluru", orderDate: ISODate("2026-03-03"), total: 3000, items: [{ product: "Electric Kettle", quantity: 2, price: 1500 }] },
  { _id: 10, customer: "Meena", city: "Bengaluru", orderDate: ISODate("2026-03-15"), total: 800, items: [{ product: "Yoga Mat", quantity: 1, price: 800 }] },
  { _id: 11, customer: "Rahul", city: "Bengaluru", orderDate: ISODate("2026-03-18"), total: 2000, items: [{ product: "Wireless Mouse", quantity: 4, price: 500 }] },
  { _id: 12, customer: "Sneha", city: "Mumbai", orderDate: ISODate("2026-03-03"), total: 5200, items: [{ product: "Office Chair", quantity: 1, price: 4000 }, { product: "USB-C Hub", quantity: 1, price: 1200 }] }
]);

const since = { $match: { orderDate: { $gte: ISODate("2026-01-01") } } };

printjson(db.orders.aggregate([
  since,
  { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$orderDate" } }, orders: { $sum: 1 }, sales: { $sum: "$total" } } },
  { $sort: { _id: 1 } }
]).toArray());

printjson(db.orders.aggregate([
  since,
  { $unwind: "$items" },
  { $group: { _id: "$items.product", revenue: { $sum: { $multiply: ["$items.quantity", "$items.price"] } } } },
  { $sort: { revenue: -1, _id: 1 } },
  { $limit: 5 }
]).toArray());

printjson(db.orders.aggregate([
  since,
  { $group: { _id: "$city", avgBasket: { $avg: "$total" } } },
  { $sort: { avgBasket: -1 } },
  { $set: { avgBasket: { $round: ["$avgBasket", 2] } } }
]).toArray());
