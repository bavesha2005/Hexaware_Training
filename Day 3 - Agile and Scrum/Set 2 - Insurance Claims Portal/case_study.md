# Case Study Documentation

This document consolidates the case study's product vision, backlog, Scrum analysis, acceptance criteria, and Jira setup.



---

## Vision statement

For policyholders who need to submit and follow an insurance claim, the Insurance Claims Portal provides a secure self-service journey to register a claim, provide supporting documents, and see settlement progress. It reduces uncertainty for customers and gives claims teams more consistent information to process requests.

## Product outcome

Deliver a usable first release that solves the central customer journey described in the business scenario. Validate assumptions with representative users and stakeholders during Sprint Reviews.

## Scope note

This vision is a proposed workshop artifact based on the supplied case study, not an approved statement from a real organisation.


---

## Epics

- Claim Registration
- Document Upload
- Claim Tracking
- Settlement Notifications

## Backlog

| ID | Epic | User story | MoSCoW / Priority | Points |
|---|---|---|---|---:|
| INS-01 | Claim Registration | As a policyholder, I want to start a claim using my policy so that I can report an incident online. | Must | 3 |
| INS-02 | Claim Registration | As a policyholder, I want to enter the incident date, type, and description so that the insurer receives the basic claim facts. | Must | 5 |
| INS-03 | Claim Registration | As a policyholder, I want the portal to validate my policy and required claim fields so that I can correct errors before submission. | Must | 5 |
| INS-04 | Claim Registration | As a policyholder, I want to submit a valid claim and receive a reference number so that I can identify my claim later. | Must | 5 |
| INS-05 | Document Upload | As a policyholder, I want to see which documents are required for my claim type so that I can prepare the correct evidence. | Must | 3 |
| INS-06 | Document Upload | As a policyholder, I want to upload a supported document so that the claims team can review evidence. | Must | 5 |
| INS-07 | Document Upload | As a policyholder, I want clear feedback when a file type or size is not accepted so that I can upload a valid document. | Should | 3 |
| INS-08 | Document Upload | As a policyholder, I want to see the documents attached to my claim so that I can confirm what I provided. | Should | 3 |
| INS-09 | Claim Tracking | As a policyholder, I want to see the current status of my claim so that I understand where it is in the process. | Must | 3 |
| INS-10 | Claim Tracking | As a policyholder, I want to view dated claim updates so that I can understand important changes to my claim. | Should | 5 |
| INS-11 | Claim Tracking | As a policyholder, I want to respond to a request for more information so that claim assessment can continue. | Should | 5 |
| INS-12 | Settlement Notifications | As a policyholder, I want to choose email or SMS claim updates so that I receive information through my preferred channel. | Could | 3 |
| INS-13 | Settlement Notifications | As a policyholder, I want to be notified when a settlement decision is available so that I know the outcome of my claim. | Must | 3 |

## Story format

Every story is written from a user perspective using the “As a…, I want…, so that…” format.


---

## Scenarios

### INS-01

Given the policyholder has an active eligible policy, When they choose Start a Claim, Then a new claim form is opened with the policy reference associated.

### INS-02

Given the claim form is open, When the policyholder enters the incident date, type, and description, Then the entered values are retained for review before submission.

### INS-03

Given a required field is missing or the policy reference is invalid, When the policyholder attempts to continue, Then the portal identifies the invalid or missing value and prevents progression until corrected.

### INS-04

Given all required claim information is valid, When the policyholder submits the claim, Then the portal creates the claim and displays a unique reference number.


## Coverage note

The scenarios above are the acceptance-criteria set explicitly required by the assignment brief. Add further scenarios as the team refines each story.


---

## Review approach

Each story is assessed against Independent, Negotiable, Valuable, Estimable, Small, and Testable. The backlog is a workshop proposal; the Product Owner and Developers should validate story boundaries before Sprint Planning.

## Review findings

All 13 stories have been checked against INVEST. Claim registration is vertically sliced into start claim (INS-01), capture incident facts (INS-02), validate the customer-entered information (INS-03), and submit with a reference (INS-04). Each slice delivers a coherent customer-facing outcome rather than creating separate UI, API, and database-only stories.
Oversized story split example: “Build the complete claim registration module” is not independently demonstrable or estimable. The vertical slices INS-01–INS-04 each span the necessary UI, service, and data work to deliver a testable customer outcome.
Document handling is also separated into checklist visibility (INS-05), upload (INS-06), validation feedback (INS-07), and document listing (INS-08).


---

## Planning Poker and total

Planning Poker scale used: 1, 2, 3, 5, 8, 13. Total estimated backlog = 51 story points. Illustrative outlier: INS-06 initially received 3 and 8. The lower estimate assumed one simple upload path; the higher estimate accounted for file validation, storage integration, security checks, and failure handling. After clarifying supported formats and size limits, the team converged on 5. These are sample workshop estimates, not recorded votes from a real team.

## Total backlog size

**51 story points** across 13 stories.


---

## Definition of Ready (DoR)

- [ ] Story is linked to one of the four agreed epics.
- [ ] User and business outcome is clear.
- [ ] Acceptance criteria include expected behaviour and relevant validation failures.
- [ ] Story is vertically sliced and small enough for a Sprint.
- [ ] Data, security, privacy, and compliance questions are identified.
- [ ] Dependencies and required decisions are visible.
- [ ] Developers understand the story and can estimate it.

## Definition of Done (DoD)

- [ ] Acceptance criteria pass for the story, including validation and error paths.
- [ ] Security and privacy requirements relevant to the change are checked.
- [ ] Code is peer-reviewed and merged.
- [ ] Automated tests pass and regression impact is assessed.
- [ ] No critical or high-severity defects remain open.
- [ ] Claim data changes are auditable where required.
- [ ] Product Owner accepts the story and the Increment meets the Definition of Done.


---

## Comparison (within the brief's half-page limit)

Waterfall typically plans major phases and requirements up front, with formal hand-offs between analysis, design, build, and testing. That can work when scope and rules are stable, but it can delay feedback when claim forms, evidence requirements, or customer needs change. Agile delivers small increments, reviews them with users and claims stakeholders, and reprioritises the backlog as learning emerges. For this portal, Agile is suitable because form usability, document requirements, status visibility, and notification preferences can be validated iteratively. Compliance, privacy, and audit controls still need explicit acceptance criteria and review; Agile does not mean skipping governance.


---

## One-page team note

Product Owner: accountable for maximising product value and ordering the Product Backlog. Scrum Master: establishes Scrum understanding, facilitates improvement, and helps remove impediments. Developers: cross-functional people who create a usable Increment. Scrum events: Sprint, Sprint Planning, Daily Scrum, Sprint Review, and Sprint Retrospective. Scrum artifacts: Product Backlog, Sprint Backlog, and Increment; each has a commitment—Product Goal, Sprint Goal, and Definition of Done respectively.


---

## Board configuration

## Board columns

| Column | Meaning |
|---|---|
| To Do | Ready work not yet started |
| In Progress | Work currently being implemented |
| In Review | Work awaiting peer review, QA, or Product Owner review |
| Done | Meets the team's Definition of Done |

## Suggested JIRA setup

1. Create a company-managed Scrum project (or the equivalent Scrum project type available in your Jira workspace).
2. Create the epics listed in `epics_and_user_stories.md`.
3. Import `jira_import.csv` using Jira's CSV import flow; map Issue Type, Summary, Description, Epic Name / Epic Link, Priority, Story Points, Status, and Labels as supported by your Jira edition.
4. Confirm every story is attached to the correct epic after import; Jira's epic field mapping differs between project types and Jira versions.
5. Configure the board columns to match the table above.
6. Add the DoR and DoD from `definition_of_ready_and_done.md` to the project documentation or team working agreement.
7. Review imported issue descriptions, priorities, and estimates with the actual team before treating them as committed backlog decisions.


