# Set 2 – Airline Web Check-in

## 1. Team capacity
Six team members × 8 working days × 8 hours/day × 70% focus factor:

**6 × 8 × 8 × 0.70 = 268.8 focused hours** (approximately 269 hours).

This is the team's available focused time, not a story-point total. Story points are relative estimates and should not be mechanically converted into hours. No historical velocity is supplied, so the team uses a cautious planning judgement of **28 points** for this simulation, then checks the actual task-hour load against the 268.8-hour capacity.

## 2. Sprint goal
Enable passengers to retrieve their booking, verify passenger details, obtain a boarding pass and view/select seat options, while safely managing the payment-gateway dependency that blocks paid seat upgrades.

## 3. Selected sprint stories
| Jira key | Story | Points | DoR decision |
|---|---|---:|---|
| CHECKIN-5 | Retrieve booking by PNR and surname | 5 | Ready: inputs, validation and error paths defined |
| CHECKIN-6 | Confirm passenger details | 3 | Ready: required fields and validation rules defined |
| CHECKIN-7 | Download boarding pass | 5 | Ready: eligibility, output format and failure path defined |
| CHECKIN-8 | View available seats | 5 | Ready: seat-map data and availability rules defined |
| CHECKIN-10 | Purchase seat upgrade | 8 | **Blocked after sprint start:** sandbox dependency unavailable |
| CHECKIN-11 | View upgrade price before payment | 2 | Ready: pricing source and display rules defined |
| **Total** | | **28** | |

The 28-point commitment is a deliberate risk-adjusted choice. The 8-point seat-upgrade story is selected but becomes blocked when the sandbox is unavailable.

## 4. Definition of Ready checklist
A story is Ready when:
1. User and business value are clear.
2. Acceptance criteria are written and testable.
3. Dependencies and external systems are identified.
4. Required data, permissions and test accounts are available or have a documented plan.
5. UX/API contracts are accessible to the team.
6. Story is small enough to complete within the sprint.
7. The team understands the story and has estimated it.

CHECKIN-10 met the initial refinement criteria with a documented sandbox dependency, but the live outage on the scenario's mid-sprint day creates a new impediment. The team does not silently treat it as unblocked.

## 5. Impediment log
| Field | Entry |
|---|---|
| Description | Payment-gateway sandbox required by the seat-upgrade story is unavailable |
| Impact | Blocks end-to-end upgrade payment integration and acceptance testing |
| Owner | Scrum Master coordinates escalation; integration developer investigates technical options |
| Escalation path | Payment provider support → airline integration lead → Product Owner / engineering manager |
| Expected resolution | Within one working day; request a provider incident reference and ETA |
| Removal action | Scrum Master raises the incident, arranges an approved mock/stub for non-production testing, keeps stakeholders informed, and facilitates re-planning if the Sprint Goal is at risk |

Jira issue **CHECKIN-14** records the impediment and removal actions.

## 6. Next-sprint refinement – top five stories
1. Complete payment-gateway upgrade integration.
2. Add payment failure and retry handling.
3. Confirm seat reservation after successful payment.
4. Release an upgraded boarding pass.
5. Add upgrade refund/cancellation handling.

**Oversized story split:** “Purchase a seat upgrade” is split vertically:
- Obtain upgrade quote and confirm passenger eligibility – 5 points.
- Authorise payment and confirm upgraded seat – 3 points.

The split delivers independently testable customer value: the first slice shows a valid quote and eligibility; the second completes the purchase and seat confirmation. Combined estimate remains 8 points after refinement.

## 7. Sprint Review agenda
1. State the Sprint Goal and explain the sandbox dependency.
2. Demonstrate booking retrieval using valid and invalid PNR/surname combinations.
3. Demonstrate passenger detail confirmation and validation errors.
4. Demonstrate boarding-pass generation for an eligible passenger.
5. Demonstrate seat-map availability and price display.
6. Show the upgrade-payment flow using a test stub only; clearly label it as simulated and not a live gateway transaction.
7. Review acceptance criteria, known limitations, and feedback.
8. Capture new backlog items and Product Owner decisions.

### Demonstration script against acceptance criteria
- Enter a valid PNR and surname; show booking details.
- Enter an invalid PNR; show a clear validation message and no check-in record.
- Confirm passenger details; show the updated passenger record.
- Generate and download the boarding pass for an eligible booking.
- Display available seats; select a seat and confirm availability is rechecked.
- Open the upgrade quote; show price and eligibility.
- Attempt payment while the sandbox is unavailable; show a controlled unavailable state and ensure no charge or seat upgrade is falsely confirmed.

## 8. Asynchronous stand-up example
**Distributed team channel – updates posted before each member's local workday overlap.**

**Developer A (India, IST)**
- Yesterday: Booking retrieval validation completed.
- Today: Add invalid-PNR and surname mismatch tests.
- Blocker: None.

**Developer B (UK, GMT)**
- Yesterday: Seat-upgrade payment adapter investigation started.
- Today: Verify provider outage and prepare a mock adapter.
- Blocker: Payment sandbox unavailable; incident raised with provider.

**Developer C (India, IST)**
- Yesterday: Boarding-pass generation path completed.
- Today: Validate passenger details and boarding-pass acceptance criteria.
- Blocker: Waiting for final sample booking data.

### Async vs live stand-up
- **Async:** Supports distributed time zones, creates a written record and allows thoughtful updates. It can delay clarification and makes it easier for blockers to remain unnoticed.
- **Live:** Enables immediate questions, shared understanding and rapid blocker escalation. It is harder to schedule across time zones and can become a status-report meeting.

