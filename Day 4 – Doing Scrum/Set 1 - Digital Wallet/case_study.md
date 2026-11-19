# Set 1 – Digital Wallet Application

## 1. Velocity and sprint commitment
Previous sprint velocities: 21, 24, 23 points.

Average velocity = (21 + 24 + 23) / 3 = **22.67 points**. Use **23 points as the planning reference**. The selected initial sprint scope is 22 points, a cautious commitment slightly below the historical average because the team is five developers and a mid-sprint request is expected to be handled.

### Sprint goal
Deliver a secure core wallet journey that lets customers fund their wallet, pay merchants, and inspect transaction activity, while preserving the ability to adapt to an urgent refund request without compromising payment correctness.

## 2. Initial sprint backlog
| Jira key | Story | Points |
|---|---|---:|
| WALLET-7 | Add money using saved bank account | 5 |
| WALLET-8 | View available balance | 2 |
| WALLET-9 | Pay merchant using wallet balance | 5 |
| WALLET-10 | View transaction history | 3 |
| WALLET-12 | Support agent checks refund status | 2 |
| WALLET-13 | Enable transaction PIN | 3 |
| WALLET-14 | Receive debit alert | 2 |
| **Total** | | **22** |

## 3. Day 4 scope change
The business asks for refund-to-wallet functionality. The Product Owner owns backlog ordering and decides the priority of the new request after discussion with stakeholders. The Developers estimate the work and negotiate what can fit without endangering the Sprint Goal. The Scrum Master facilitates the conversation and protects the team from an unplanned, unilateral scope injection.

- **Added:** WALLET-11 – refund an eligible cancelled purchase to the wallet (5 points).
- **Removed from the sprint:** WALLET-13 – enable transaction PIN (3 points), and WALLET-14 – receive debit alert (2 points).
- **Net sprint scope:** 22 points before and after the change.
- **Decision:** Product Owner reprioritises; Product Owner and Developers collaborate on scope adjustment. The Scrum Master facilitates, but does not independently decide product priority.

The sprint goal remains viable because the new refund story extends the wallet transaction flow and the team swaps out two lower-priority security enhancements rather than expanding capacity.

## 4. Task breakdown – three selected stories
| Parent story | Task | Estimate |
|---|---|---:|
| WALLET-7 | Implement bank-account funding request validation | 6 h |
| WALLET-7 | Integrate bank payment response and wallet credit | 8 h |
| WALLET-7 | Add funding success and failure tests | 4 h |
| WALLET-9 | Build merchant payment confirmation flow | 6 h |
| WALLET-9 | Implement atomic wallet debit and ledger entry | 8 h |
| WALLET-9 | Test insufficient balance and duplicate payment cases | 4 h |
| WALLET-10 | Create paginated transaction history endpoint | 5 h |
| WALLET-10 | Build transaction history screen and filters | 6 h |
| WALLET-10 | Add sorting, pagination and access-control tests | 3 h |
| **Total** | | **50 h** |

These are task-hour estimates, not story-point conversions. Jira subtasks WALLET-16 through WALLET-24 hold the breakdown.

## 5. Day 3 stand-up updates
**Developer 1 – Payments**
- Yesterday: Completed the bank-funding request validation.
- Today: Integrate the payment-provider response and wallet credit.
- Impediment: Waiting for the sandbox test credentials to be refreshed.

**Developer 2 – Wallet ledger**
- Yesterday: Implemented the merchant debit and ledger transaction.
- Today: Add duplicate-payment and insufficient-balance tests.
- Impediment: Needs confirmation of the idempotency-key retention rule.

**Developer 3 – Transaction history**
- Yesterday: Completed the transaction-history API pagination.
- Today: Connect the screen filters to the API.
- Impediment: Sample data contains inconsistent transaction timestamps; needs a canonical timezone rule.

## 6. Impediment log
| ID | Description | Impact | Owner | Next action |
|---|---|---|---|---|
| W-IMP-01 | Payment sandbox credentials need refresh | Delays integration tests | Scrum Master + payment developer | Contact provider, obtain refreshed credentials, use a mock response meanwhile |
| W-IMP-02 | Idempotency retention rule unclear | Risk of duplicate refunds/debits | Product Owner + backend lead | Confirm policy and add it to acceptance criteria |

## 7. Sprint burndown
The completed-points table below is simulated because the assignment did not supply one. Remaining work is recalculated after the Day 4 scope-neutral swap.

| Day | Points completed | Scope added | Scope removed | Remaining points |
|---:|---:|---:|---:|---:|
| Start | 0 | 0 | 0 | 22 |
| 1 | 2 | 0 | 0 | 20 |
| 2 | 0 | 0 | 0 | 20 |
| 3 | 3 | 0 | 0 | 17 |
| 4 | 0 | 5 | 5 | 17 |
| 5 | 3 | 0 | 0 | 14 |
| 6 | 2 | 0 | 0 | 12 |
| 7 | 3 | 0 | 0 | 9 |
| 8 | 0 | 0 | 0 | 9 |
| 9 | 2 | 0 | 0 | 7 |
| 10 | 2 | 0 | 0 | 5 |


## 8. Retrospective
### What went well
- The team kept the sprint goal visible during the refund request.
- Payment and ledger work was decomposed into testable tasks.
- The Product Owner and Developers negotiated a scope-neutral change.



### Action items
| SMART action | Owner | Due |
|---|---|---|
| Validate payment sandbox credentials and run one smoke transaction before every sprint planning session | Payments developer | Before next sprint planning |
| Add an agreed idempotency and refund-policy section to the wallet acceptance-criteria template | Product Owner + backend lead | Within 3 working days |

## 9. Definition of Done mapped to build pipeline
- **Build:** Code compiles; dependency and configuration checks pass; build artifact is reproducible.
- **Test:** Unit tests and relevant integration tests pass; negative payment/refund cases are covered; no critical test failures remain.
- **Review:** Pull request is reviewed; security-sensitive wallet and ledger changes receive a second reviewer; acceptance criteria are checked.
- **Merge:** Approved changes are merged to the protected branch; CI is green; migration/configuration notes are included; the story is demonstrable and accepted by the Product Owner.

