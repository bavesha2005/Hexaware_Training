# Set 3 – E-Learning Platform

## 1. Sprint plan
Supplied velocity: **30 story points**. Use 30 points as the planning reference.

### Sprint Goal
Help learners discover and enrol in courses, continue learning, track assessment outcomes and understand completion eligibility, providing a reliable foundation for course completion.

### Initial sprint backlog
| Jira key | Story | Points |
|---|---|---:|
| ELEARN-4 | Browse available courses | 5 |
| ELEARN-5 | Enrol in a course | 5 |
| ELEARN-6 | Resume a course from last position | 3 |
| ELEARN-7 | Take a course assessment | 5 |
| ELEARN-8 | See assessment result | 2 |
| ELEARN-9 | See certificate eligibility | 3 |
| **Total** | | **23** |

The team plans 23 points, below the 30-point velocity reference, leaving room for uncertainty and the known API dependency.

## 2. Day 6 scope-change analysis
The Product Owner requests certificate download for an upcoming launch.

- **Added:** ELEARN-13 – urgent certificate download for launch (5 points).
- **Removed:** ELEARN-7 – take a course assessment (5 points), moved to the product backlog for a later sprint.
- **Kept:** course discovery, enrolment, resume learning, assessment result and certificate eligibility.
- **Net sprint scope:** 23 points before and after the swap.

The Product Owner decides priority and explains the launch value. The Developers assess the work and agree what can be swapped without endangering the Sprint Goal. The Scrum Master facilitates the conversation and makes the API dependency visible. The Sprint Goal is protected by keeping the learning journey and eligibility foundation while exchanging one 5-point story for the urgent 5-point certificate-download slice.

## 3. Missing API contract – stand-up and Scrum Master follow-up
**Developer update**
- Yesterday: Completed the certificate screen and local download-state handling.
- Today: Integrate the certificate service once its API contract is available; prepare contract tests against a mock.
- Impediment: The certificate API contract is missing, so request fields, authentication and error responses cannot be confirmed.

**Scrum Master follow-up**
1. Contact the API owner and engineering lead immediately.
2. Arrange a short contract clarification with the developer and Product Owner.
3. Request endpoint schema, authentication requirements, sample payloads and error codes.
4. Agree a delivery time and escalate if the contract is not supplied by the next working day.
5. Enable a temporary mock contract so independent UI and test work can continue.
6. Update the impediment log and make the risk visible at the next Daily Scrum.

Jira issue **ELEARN-12** records the impediment and follow-up.

## 4. Sprint velocity calculation
For this simulation, assume the completed-points table is:

| Story | Estimate | End-of-sprint result | Points counted |
|---|---:|---|---:|
| Course browsing | 5 | Done | 5 |
| Course enrolment | 5 | Done | 5 |
| Resume course | 3 | Done | 3 |
| Assessment result | 2 | Done | 2 |
| Certificate eligibility | 3 | Done | 3 |
| Urgent certificate download | 5 | 80% complete, not meeting DoD | 0 |
| **Total** | **23** | | **18** |

**Sprint velocity = 18 story points.**


## 5. Retrospective – Start / Stop / Continue
### Start
- Publish API contracts and sample payloads before stories enter sprint planning.
- Add dependency owners and expected response dates to refinement notes.

### Stop
- Stop treating “almost complete” stories as Done.
- Stop beginning integration work when required contracts are unknown and no mock is available.

### Continue
- Continue keeping sprint scope changes transparent.
- Continue using acceptance criteria and automated tests to make Done verifiable.

### Three SMART action items
| Action | Measure | Owner | Due |
|---|---|---|---|
| Publish API contract for every sprint-selected integration story | 100% of selected API stories have schema, auth and error examples attached | API lead | Before next sprint planning |
| Add contract-test mock to the certificate service pipeline | Mock contract tests run in CI and pass on every pull request | Backend developer | Within 5 working days |
| Enforce DoD-based velocity reporting | Sprint report counts only stories accepted as Done; zero partial-point credit | Scrum Master | Starting next sprint review |

## 6. How automation supports the Definition of Done
- **Unit tests:** Verify business rules such as course completion, eligibility and certificate permissions at the smallest practical level.
- **Linting and static checks:** Catch style, type and common defect issues before review.
- **Build pipeline:** Ensures the application compiles and dependencies resolve consistently.
- **Integration/contract tests:** Verify the application communicates with the certificate API using agreed request/response contracts.
- **Pull-request review:** Ensures code quality, security and acceptance criteria are checked by another developer.
- **Merge gate:** Prevents merging when required checks fail, so the main branch remains in a releasable state.

