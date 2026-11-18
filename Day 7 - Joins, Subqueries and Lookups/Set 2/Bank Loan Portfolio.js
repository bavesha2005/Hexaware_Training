
use('bank_loan_portfolio');

// 1. Loans with customer details and all repayments

db.loans.aggregate([
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
      from: 'repayments',
      localField: 'loan_id',
      foreignField: 'loan_id',
      as: 'repayments'
    }
  },
  {
    $project: {
      _id: 0,
      loan_id: 1,
      loan_type: 1,
      principal_amount: 1,
      outstanding_balance: 1,
      customer: {
        customer_id: '$customer.customer_id',
        customer_name: '$customer.customer_name',
        email: '$customer.email'
      },
      repayments: 1
    }
  }
]);

// 2. Customers with their loan portfolio and total exposure

db.customers.aggregate([
  {
    $lookup: {
      from: 'loans',
      localField: 'customer_id',
      foreignField: 'customer_id',
      as: 'loans'
    }
  },
  {
    $project: {
      _id: 0,
      customer_id: 1,
      customer_name: 1,
      email: 1,
      loan_count: { $size: '$loans' },
      total_loan_exposure: {
        $sum: '$loans.outstanding_balance'
      },
      loans: 1
    }
  }
]);

// 3. Each loan with its most recent repayment

db.loans.aggregate([
  {
    $lookup: {
      from: 'repayments',
      let: {
        currentLoanId: '$loan_id'
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $eq: ['$loan_id', '$$currentLoanId']
            }
          }
        },
        {
          $sort: {
            repayment_date: -1,
            repayment_id: -1
          }
        },
        {
          $limit: 1
        }
      ],
      as: 'last_repayment'
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
    $unwind: {
      path: '$last_repayment',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $project: {
      _id: 0,
      loan_id: 1,
      loan_type: 1,
      outstanding_balance: 1,
      customer_name: '$customer.customer_name',
      last_repayment: {
        repayment_id: '$last_repayment.repayment_id',
        repayment_date: '$last_repayment.repayment_date',
        amount_paid: '$last_repayment.amount_paid',
        payment_mode: '$last_repayment.payment_mode'
      }
    }
  }
]);
