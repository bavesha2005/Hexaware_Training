// Run in mongosh. Example source documents:
// db.customer_communications.insertMany([
//  {customer_id:1,channel:"Email",subject:"Claim issue",is_complaint:true,is_resolved:false},
//  {customer_id:2,channel:"Phone",subject:"Policy query",is_complaint:false,is_resolved:false}
// ]);
db.createView(
  "vw_unresolved_complaints",
  "customer_communications",
  [
    {$match: {is_complaint: true, is_resolved: false}},
    {$project: {_id: 1, customer_id: 1, channel: 1, subject: 1, created_at: 1}}
  ]
);
db.vw_unresolved_complaints.find();
