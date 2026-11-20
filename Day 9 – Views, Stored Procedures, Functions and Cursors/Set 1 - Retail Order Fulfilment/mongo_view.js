// db.orders.insertMany([
//  {_id:1001,order_status:"Pending",customer_name:"Asha Kumar"},
//  {_id:1002,order_status:"Pending",customer_name:"Ravi Shah"},
//  {_id:1003,order_status:"Shipped",customer_name:"Meera Das"}
// ]);
db.createView(
  "vw_order_status_counts",
  "orders",
  [
    {$group: {_id: "$order_status", orderCount: {$sum: 1}}},
    {$project: {_id: 0, orderStatus: "$_id", orderCount: 1}},
    {$sort: {orderStatus: 1}}
  ]
);
db.vw_order_status_counts.find();
