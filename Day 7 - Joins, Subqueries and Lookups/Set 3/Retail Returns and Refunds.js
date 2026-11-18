
use('retail_returns_refunds');

// 1. Returns joined with customer, product, refund and feedback details

db.returns.aggregate([
  {
    $lookup: {
      from: 'customers',
      localField: 'customer_id',
      foreignField: 'customer_id',
      as: 'customer'
    }
  },
  {
    $unwind: {
      path: '$customer',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: 'order_items',
      localField: 'order_item_id',
      foreignField: 'order_item_id',
      as: 'order_item'
    }
  },
  {
    $unwind: {
      path: '$order_item',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: 'products',
      localField: 'order_item.product_id',
      foreignField: 'product_id',
      as: 'product'
    }
  },
  {
    $unwind: {
      path: '$product',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: 'refunds',
      localField: 'return_id',
      foreignField: 'return_id',
      as: 'refunds'
    }
  },
  {
    $lookup: {
      from: 'returns_feedback',
      localField: 'return_id',
      foreignField: 'return_id',
      as: 'feedback'
    }
  },
  {
    $project: {
      _id: 0,
      return_id: 1,
      return_date: 1,
      return_quantity: 1,
      return_reason: 1,
      customer_name: '$customer.customer_name',
      product_name: '$product.product_name',
      refunds: 1,
      feedback: 1
    }
  }
]);

// 2. Stores with their returns, refunds and refund totals

db.stores.aggregate([
  {
    $lookup: {
      from: 'returns',
      localField: 'store_id',
      foreignField: 'store_id',
      as: 'returns'
    }
  },
  {
    $unwind: {
      path: '$returns',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: 'refunds',
      localField: 'returns.return_id',
      foreignField: 'return_id',
      as: 'refunds'
    }
  },
  {
    $group: {
      _id: {
        store_id: '$store_id',
        store_name: '$store_name',
        region: '$region'
      },
      return_count: {
        $sum: {
          $cond: [
            { $ne: ['$returns.return_id', null] },
            1,
            0
          ]
        }
      },
      refund_value: {
        $sum: {
          $sum: '$refunds.refund_amount'
        }
      },
      returns: { $push: '$returns' }
    }
  },
  {
    $project: {
      _id: 0,
      store_id: '$_id.store_id',
      store_name: '$_id.store_name',
      region: '$_id.region',
      return_count: 1,
      refund_value: 1,
      returns: 1
    }
  },
  {
    $sort: { refund_value: -1 }
  }
]);

// 3. Customer feedback for returns, including customer and return details

db.returns_feedback.aggregate([
  {
    $lookup: {
      from: 'returns',
      localField: 'return_id',
      foreignField: 'return_id',
      as: 'return'
    }
  },
  {
    $unwind: {
      path: '$return',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: 'customers',
      localField: 'customer_id',
      foreignField: 'customer_id',
      as: 'customer'
    }
  },
  {
    $unwind: {
      path: '$customer',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $project: {
      _id: 0,
      feedback_id: 1,
      rating: 1,
      feedback_text: 1,
      feedback_date: 1,
      customer_name: '$customer.customer_name',
      return_id: '$return.return_id',
      return_reason: '$return.return_reason',
      return_date: '$return.return_date'
    }
  }
]);
