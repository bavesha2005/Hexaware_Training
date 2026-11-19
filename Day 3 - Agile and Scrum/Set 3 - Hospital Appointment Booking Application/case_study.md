# Case Study Documentation

This document consolidates the case study's product vision, backlog, Scrum analysis, acceptance criteria, and Jira setup.



---

## Vision statement

For patients and caregivers who need timely access to doctors, the Hospital Appointment Booking Application provides a convenient way to find appointment availability, book or change a visit, and receive reminders. It helps patients manage appointments while giving hospital staff a clearer view of doctor schedules.

## Product outcome

Deliver a usable first release that solves the central customer journey described in the business scenario. Validate assumptions with representative users and stakeholders during Sprint Reviews.

## Scope note

This vision is a proposed workshop artifact based on the supplied case study, not an approved statement from a real organisation.


---

## Epics

- Booking
- Rescheduling and Cancellation
- Reminders
- Doctor Schedule Management

## Backlog

| ID | Epic | User story | MoSCoW / Priority | Points |
|---|---|---|---|---:|
| HOS-01 | Booking | As a patient, I want to browse doctors by specialty so that I can find a suitable clinician. | Must | 3 |
| HOS-02 | Booking | As a patient, I want to view a doctor's available appointment slots so that I can choose a convenient time. | Must | 5 |
| HOS-03 | Booking | As a patient, I want to book an available appointment slot so that I can reserve a consultation. | Must | 5 |
| HOS-04 | Booking | As a patient, I want to receive a booking confirmation so that I know my appointment is scheduled. | Must | 2 |
| HOS-05 | Rescheduling and Cancellation | As a patient, I want to view my upcoming appointments so that I can manage my visits. | Must | 3 |
| HOS-06 | Rescheduling and Cancellation | As a patient, I want to select another available slot for an existing appointment so that I can change my visit time. | Should | 5 |
| HOS-07 | Rescheduling and Cancellation | As a patient, I want to cancel an appointment within the allowed policy so that the slot can be made available to others. | Must | 3 |
| HOS-08 | Rescheduling and Cancellation | As a patient, I want confirmation after cancellation so that I know the appointment is no longer active. | Should | 2 |
| HOS-09 | Reminders | As a patient, I want to choose an available reminder channel so that I receive appointment reminders in a useful way. | Could | 3 |
| HOS-10 | Reminders | As a patient, I want to receive a reminder before my appointment so that I can prepare to attend. | Should | 5 |
| HOS-11 | Doctor Schedule Management | As a doctor, I want to view my published appointment schedule so that I can plan my clinic sessions. | Must | 3 |
| HOS-12 | Doctor Schedule Management | As authorised clinic staff, I want to block a doctor's unavailable time so that patients cannot book during that period. | Must | 5 |

## Story format

Every story is written from a user perspective using the “As a…, I want…, so that…” format.


---

## Scenarios

### HOS-02

Given a doctor has published availability, When a patient opens the doctor's appointment calendar, Then only bookable slots are displayed.

### HOS-03

Given a selected slot is still available, When the patient confirms the booking, Then the system reserves the slot and displays a booking confirmation.

### HOS-03 negative

Given another patient has already booked the selected slot, When the patient attempts to confirm the booking, Then the system does not create a second booking and asks the patient to select another available slot.

### HOS-06

Given the patient has an upcoming appointment, When they select a different available slot and confirm the change, Then the original booking is updated and the new appointment time is shown.

### HOS-07

Given the appointment is eligible for cancellation, When the patient confirms cancellation, Then the appointment status changes to Cancelled and the patient sees a confirmation.


## Coverage note

The scenarios above are the acceptance-criteria set explicitly required by the assignment brief. Add further scenarios as the team refines each story.


---

## Review approach

Each story is assessed against Independent, Negotiable, Valuable, Estimable, Small, and Testable. The backlog is a workshop proposal; the Product Owner and Developers should validate story boundaries before Sprint Planning.

## Review findings

All 12 stories are reviewed for INVEST. The broad story “Manage my appointments” is split into view upcoming appointments (HOS-05), reschedule (HOS-06), cancel (HOS-07), and receive cancellation confirmation (HOS-08).
Rewrite example: “Book, change, and cancel appointments” combined distinct user outcomes and was difficult to test as one story. The four stories above can be prioritised and accepted independently.
“Manage doctor schedules” is split into viewing a published schedule (HOS-11) and blocking unavailable time (HOS-12), each with a distinct user and testable outcome.


---

## Planning Poker and story points

Planning Poker estimates use Fibonacci values. Illustrative total backlog = 44 story points. HOS-04 (2 points) is used as a small reference story: a confirmation message after a successful booking, assuming the booking event already exists. HOS-03 (5 points) is larger because it must safely reserve an available slot and handle a competing booking. A story point is a relative estimate of effort, complexity, and uncertainty; it is not a fixed number of hours. Planning Poker estimates are illustrative team consensus, not actual recorded votes.

## Business value versus effort

Prioritise using business value against effort. Must items protect the core patient journey and schedule integrity. Should items improve appointment management and reminders. Could items add convenience but can wait if capacity is limited. The initial ordering is a reasoned workshop proposal and should be validated with hospital stakeholders.


---

## Definition of Ready (DoR)

- [ ] Story is linked to one of the four appointment epics.
- [ ] The patient, staff, or doctor outcome is explicit.
- [ ] Acceptance criteria are testable and include relevant failure paths.
- [ ] Booking rules and cancellation policy are clarified.
- [ ] Schedule and slot-conflict dependencies are understood.
- [ ] Story is small enough to complete in a Sprint.
- [ ] The team understands and estimates the story.

## Definition of Done (DoD)

- [ ] Acceptance criteria pass, including the already-booked-slot conflict case.
- [ ] Patient and staff permissions are checked for affected actions.
- [ ] Relevant privacy and patient-data handling checks are complete.
- [ ] Code is reviewed and merged; automated tests pass.
- [ ] Booking conflicts and schedule edge cases are regression-tested.
- [ ] No critical or high-severity defects remain open.
- [ ] Product Owner accepts the story against its criteria.


---

## Stakeholder map

| Stakeholder | Mapping requested by the brief | Reason |
|---|---|---|
| Hospital product manager | Product Owner | Represents hospital priorities and orders the product backlog. |
| Scrum facilitator | Scrum Master | Coaches the team in Scrum and helps remove impediments. |
| Software engineers, QA, UX and integration specialists | Developers | Build, test, and deliver the usable application increment. |
| Patients and caregivers | Customer | Use the booking service and provide feedback on the experience. |
| Doctors and clinical staff | Customer / stakeholder | Need accurate schedules and appointment information. |
| Reception and appointment desk staff | Customer / stakeholder | Support booking changes and handle operational exceptions. |
| Hospital IT and privacy team | Stakeholder | Advise on identity, access, integration, and protection of patient information. |


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

