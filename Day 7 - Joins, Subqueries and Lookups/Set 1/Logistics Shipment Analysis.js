
use('logistics_shipment_analysis');

// 1. Shipments with their delivery events
db.shipments.aggregate([
  {
    $lookup: {
      from: 'delivery_events',
      localField: 'shipment_id',
      foreignField: 'shipment_id',
      as: 'delivery_events'
    }
  },
  {
    $project: {
      _id: 0,
      shipment_id: 1,
      customer_id: 1,
      carrier_id: 1,
      status: 1,
      delivery_events: 1
    }
  }
]);

// 2. Customers with their shipments
db.customers.aggregate([
  {
    $lookup: {
      from: 'shipments',
      localField: 'customer_id',
      foreignField: 'customer_id',
      as: 'shipments'
    }
  },
  {
    $project: {
      _id: 0,
      customer_id: 1,
      customer_name: 1,
      email: 1,
      shipment_count: { $size: '$shipments' },
      shipments: 1
    }
  }
]);

// 3. Carriers with delay statistics
db.carriers.aggregate([
  {
    $lookup: {
      from: 'shipments',
      localField: 'carrier_id',
      foreignField: 'carrier_id',
      as: 'shipments'
    }
  },
  {
    $project: {
      _id: 0,
      carrier_id: 1,
      carrier_name: 1,
      shipment_count: { $size: '$shipments' },
      delivered_shipments: {
        $filter: {
          input: '$shipments',
          as: 'shipment',
          cond: { $ne: ['$$shipment.actual_delivery_date', null] }
        }
      }
    }
  },
  {
    $project: {
      carrier_id: 1,
      carrier_name: 1,
      shipment_count: 1,
      average_delay_days: {
        $let: {
          vars: {
            delivered: '$delivered_shipments'
          },
          in: {
            $cond: [
              { $gt: [{ $size: '$$delivered' }, 0] },
              {
                $avg: {
                  $map: {
                    input: '$$delivered',
                    as: 'shipment',
                    in: {
                      $dateDiff: {
                        startDate: '$$shipment.expected_delivery_date',
                        endDate: '$$shipment.actual_delivery_date',
                        unit: 'day'
                      }
                    }
                  }
                }
              },
              null
            ]
          }
        }
      }
    }
  }
]);
