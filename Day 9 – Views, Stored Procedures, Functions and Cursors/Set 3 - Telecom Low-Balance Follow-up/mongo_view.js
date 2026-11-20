// Run in mongosh. Example source documents:
// db.notification_log.insertMany([
//  {subscriber_id:1,message:"Low balance",is_read:false},
//  {subscriber_id:1,message:"Recharge successful",is_read:true},
//  {subscriber_id:2,message:"Low balance",is_read:false}
// ]);
db.createView(
  "vw_unread_notifications_by_subscriber",
  "notification_log",
  [
    {$match: {is_read: false}},
    {$group: {_id: "$subscriber_id", unreadCount: {$sum: 1}}},
    {$project: {_id: 0, subscriber_id: "$_id", unreadCount: 1}},
    {$sort: {subscriber_id: 1}}
  ]
);
db.vw_unread_notifications_by_subscriber.find();
