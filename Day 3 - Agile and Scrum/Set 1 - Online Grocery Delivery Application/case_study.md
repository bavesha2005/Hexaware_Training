# Case Study Documentation

This document consolidates the case study's product vision, backlog, Scrum analysis, acceptance criteria, and Jira setup.



---

## Vision statement

For local supermarket customers who need convenient grocery shopping, the Online Grocery Delivery Application provides a simple way to discover products, place orders, and follow deliveries from home. Unlike phone-based ordering, it gives customers a clear digital shopping journey and gives the supermarket a manageable channel for fulfilment.

## Product outcome

Deliver a usable first release that solves the central customer journey described in the business scenario. Validate assumptions with representative users and stakeholders during Sprint Reviews.

## Scope note

This vision is a proposed workshop artifact based on the supplied case study, not an approved statement from a real organisation.


---

## Epics

- Browse and Search
- Cart and Checkout
- Delivery Tracking

## Backlog

| ID | Epic | User story | MoSCoW / Priority | Points |
|---|---|---|---|---:|
| GRO-01 | Browse and Search | As a customer, I want to browse grocery categories so that I can find products by type. | Must | 3 |
| GRO-02 | Browse and Search | As a customer, I want to search products by name so that I can quickly find an item. | Must | 5 |
| GRO-03 | Browse and Search | As a customer, I want to view a product's price, size, and availability so that I can decide whether to add it to my basket. | Must | 3 |
| GRO-04 | Browse and Search | As a customer, I want to filter search results by brand and price range so that I can narrow my choices. | Should | 5 |
| GRO-05 | Cart and Checkout | As a customer, I want to add an available product to my cart so that I can collect items before checkout. | Must | 2 |
| GRO-06 | Cart and Checkout | As a customer, I want to change an item's quantity in my cart so that my order reflects the amount I need. | Must | 3 |
| GRO-07 | Cart and Checkout | As a customer, I want to see the cart subtotal and delivery charge so that I understand the expected cost before placing an order. | Must | 3 |
| GRO-08 | Cart and Checkout | As a customer, I want to confirm my address and place my order so that the supermarket can prepare my groceries. | Must | 8 |
| GRO-09 | Cart and Checkout | As a customer, I want to choose an available delivery slot so that my order arrives at a convenient time. | Should | 5 |
| GRO-10 | Delivery Tracking | As a customer, I want an order confirmation with an order number so that I know my order was received. | Must | 2 |
| GRO-11 | Delivery Tracking | As a customer, I want to see whether my order is being prepared, dispatched, or delivered so that I know its progress. | Should | 5 |
| GRO-12 | Delivery Tracking | As a customer, I want a notification when my order is out for delivery so that I can be ready to receive it. | Could | 3 |

## Story format

Every story is written from a user perspective using the “As a…, I want…, so that…” format.


---

## Scenarios

### GRO-01

Given the customer is on the home screen, When the customer selects “Fruits and Vegetables”, Then the application displays products assigned to that category.

### GRO-02

Given the catalogue contains “Whole Wheat Bread”, When the customer searches for “bread”, Then matching available products are shown.

### GRO-03

Given a product is listed, When the customer opens its details, Then the current price, pack size, and availability are displayed.

### GRO-05

Given a product is available, When the customer selects Add to Cart, Then the cart contains that product with quantity one.

### GRO-05 negative

Given a product has become unavailable, When the customer attempts to add it to the cart, Then the application prevents the addition and displays an availability message.


## Coverage note

The scenarios above are the acceptance-criteria set explicitly required by the assignment brief. Add further scenarios as the team refines each story.


---

## Review approach

Each story is assessed against Independent, Negotiable, Valuable, Estimable, Small, and Testable. The backlog is a workshop proposal; the Product Owner and Developers should validate story boundaries before Sprint Planning.

## Review findings

GRO-01 to GRO-12: stories are reviewed for Independent, Negotiable, Valuable, Estimable, Small, and Testable characteristics. The initial broad story “Manage my entire grocery order” was rejected because it bundled browsing, checkout, payment, and delivery. It was split into GRO-01 through GRO-12 as customer-visible slices.
Rewrite 1: “Search and manage all products” was too broad. Rewritten as GRO-02 (search by name) and GRO-04 (filter results).
Rewrite 2: “Checkout and delivery” combined several outcomes. Rewritten as GRO-08 (place order) and GRO-09 (choose delivery slot), with confirmation and tracking separated into GRO-10 and GRO-11.


---

## Estimation approach

Reference story: GRO-05 Add an item to cart = 2 points. The team treats a straightforward, single-screen cart action with known product availability as its baseline. GRO-01 (3 points) is slightly larger because category browsing needs navigation and catalogue grouping. GRO-08 (8 points) is larger due to address confirmation, order validation, and order creation. Planning Poker is a team discussion; the estimates below are an illustrative consensus for this workshop, not actual votes from named participants.

## MoSCoW prioritisation

MoSCoW is used: Must = essential first usable shopping journey; Should = important usability/convenience improvements; Could = useful enhancement if capacity remains. Won't-have is not assigned to a story in this 12-story initial scope; items outside scope should be recorded separately.


---

## Definition of Ready (DoR)

- [ ] Story has a clear user and business outcome.
- [ ] Story is linked to an epic and ordered in the backlog.
- [ ] Acceptance criteria are written and testable.
- [ ] Dependencies and external decisions are identified.
- [ ] Story is small enough to complete in one Sprint.
- [ ] Design, data, and policy questions needed to start are answered.
- [ ] The team understands the story and can estimate it.

## Definition of Done (DoD)

- [ ] Acceptance criteria are met and demonstrated.
- [ ] Code is reviewed and merged.
- [ ] Automated tests pass; relevant regression tests pass.
- [ ] No known critical or high-severity defects remain open.
- [ ] Accessibility and basic responsive behaviour are checked for changed UI.
- [ ] Product Owner accepts the story against its acceptance criteria.
- [ ] Documentation and release notes are updated where needed.


---

## Role table

| Scrum role | Accountability in this case | Example anti-pattern |
|---|---|---|
| Product Owner | Represents customer and business value, orders the Product Backlog, and clarifies product goals. | Anti-pattern: acts as a ticket secretary who accepts every stakeholder request without making priority decisions. |
| Scrum Master | Helps the team understand Scrum, removes impediments, and improves collaboration. | Anti-pattern: behaves as a command-and-control project manager who assigns every task and directs Developers. |
| Developers | Create a usable, tested Increment each Sprint and decide how to do the work. | Anti-pattern: wait for detailed task-by-task instructions and treat quality as someone else's responsibility. |


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


