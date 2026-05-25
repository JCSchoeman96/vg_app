# Controlled Vertical Slice Development Workflow

**Purpose:** This document defines the development workflow for building an Ash 3.x / Phoenix / Elixir project using planning packs, tracer bullets, vertical slices, tests, and controlled backend expansion.

It is intended to be used as reusable project context for human collaborators, ChatGPT agents, Codex agents, architecture reviewers, and implementation agents.

---

## 1. Core Principle

Do **not** build the whole backend first.

Do **not** build random frontend features first.

Do **not** let agents invent future architecture because “we will probably need it later.”

Instead, build the project through a controlled loop:

```text
Plan the next thin vertical outcome
→ Grill it
→ Patch the planning pack
→ Build only the backend/foundation needed for that slice
→ Prove it with tests
→ Add minimal UI only when the backend law is stable
→ Merge
→ Choose the next vertical slice
→ Repeat
```

This is not “backtracking.”  
It is **controlled forward movement with feedback loops**.

The goal is to keep planning, implementation, and verification tightly aligned while preventing scope creep, vague implementation, and agent hallucination.

---

## 2. Mental Model

Use this model throughout the project:

```text
Planning Pack = the law
Vertical Slice = the work order
Tests = the court
Code = the implementation
Next Patch = new law after new decisions
```

A coding agent may only implement what the current planning pack and the selected slice allow.

If a required detail is missing, the correct agent behaviour is to stop and report the gap — not to invent a field, action, state, or workflow.

---

## 3. Planning Pack Role

The latest planning pack is the current legal baseline.

Example:

```text
voelgoed-ash-agent-pack-v0.2.7.zip
```

This does **not** mean the whole pack is ready to code.

It means:

```text
v0.2.7 = current project law and constraints
```

A specific slice inside the pack must still be grilled, patched, and marked coding-ready before an implementation agent may build it.

### Correct usage

```text
Take latest baseline: v0.2.7
Choose next slice: VS-000
Grill that slice
Patch docs to make that slice coding-ready
Implement only that slice
Run tests
Merge
Repeat
```

### Incorrect usage

```text
Give v0.2.7 to an agent and say: “Build the whole thing.”
```

That is too broad and invites scope creep.

---

## 4. Tracer Bullet vs Vertical Slice

### 4.1 Tracer Bullet

A tracer bullet proves that an architectural path works end-to-end.

It may be mostly backend code and tests.

It does not need polished UI.

Example:

```text
Confirmed User
→ MembershipProduct
→ MembershipPlan
→ Offer
→ Price
→ Pending Order
→ Paystack verified success fixture
→ PaymentEvent
→ PaymentMethod capture
→ Paid Order
→ Active Membership
→ Active EntitlementGrants
→ Access evaluation returns true
```

A tracer bullet answers:

```text
Can this whole chain work correctly at all?
```

### 4.2 Vertical Slice

A vertical slice delivers a real product capability.

Example:

```text
A real user can register, confirm email, choose a membership plan, pay, and receive access.
```

A vertical slice answers:

```text
Can a user actually use this feature safely?
```

### 4.3 Relationship between them

The normal workflow is:

```text
Tracer bullet first
→ prove the backend spine
→ then build real vertical slices on top of the proven path
```

---

## 5. The Standard Development Loop

Every significant feature should move through this loop.

---

### Step 1 — Select the next outcome

Choose one narrow outcome.

Examples:

```text
VS-000 — Backend tracer bullet
VS-001A — Register user with AshAuthentication and consent records
VS-002A — Configure membership product, plans, benefit rules, offer, and prices
VS-002B — Create or reuse pending order
VS-002C — Verify Paystack payment event
VS-002D — Activate membership and entitlement grants
VS-002E — Evaluate access
VS-002F — PaymentMethod capture and recurring-readiness gates
```

Do not select multiple slices unless they are explicitly bundled by the planning pack.

---

### Step 2 — Run `/grill-me` on that slice

Before implementation, pressure-test the slice.

The `/grill-me` session must expose:

- missing resources
- missing fields
- missing Ash action definitions
- unclear state transitions
- unclear actor permissions
- vague return shapes
- missing validations
- missing policies
- side-effect ambiguity
- orchestration ambiguity
- transaction boundary gaps
- deferred features accidentally leaking into active scope
- missing tests
- places where the coding agent would need to guess

The goal is not to improve writing style.

The goal is to make the slice implementation-safe.

---

### Step 3 — Patch the planning pack

After the grill session, generate a new planning patch.

Example:

```text
v0.2.7 = current baseline
/grill-me VS-000
→ v0.2.8 = VS-000 coding-ready patch
```

The patch should:

- preserve the current baseline where possible
- apply only the decisions needed for the selected slice
- update resource cards
- update action cards
- update state-transition maps
- update test matrix
- update actor/permission matrix
- update validator rules if needed
- add a changelog
- add a validation report

Only the grilled slice should be marked coding-ready.

The whole pack should not be marked coding-ready unless every active slice has passed the same process.

---

### Step 4 — Implement only the selected slice

The coding agent receives the coding-ready planning pack and the selected slice.

The agent must obey these rules:

```text
Implement only the selected slice.
Do not implement deferred resources.
Do not implement future slices.
Do not add fields/actions/states not required by the selected slice unless the pack explicitly requires them.
If a required detail is missing, stop and report the gap.
All IDs must follow the platform ID standard.
All timestamps must follow the platform timestamp standard.
All tests listed for the selected slice must pass.
```

For this project, the current global technical locks are:

```text
All primary IDs SHALL use UUIDv7.
All persisted timestamps SHALL use UTC microsecond precision.
UUIDv7 ordering MAY be used as a secondary technical ordering aid.
UUIDv7 ordering SHALL NOT be authoritative business event ordering.
Business ordering SHALL use explicit timestamps, provider metadata, event sequence, ledger sequence, or domain-specific ordering rules.
```

---

### Step 5 — Prove with tests

A slice is not complete because the code compiles.

A slice is complete only when:

- required unit tests pass
- required domain/action tests pass
- required integration tests pass
- idempotency tests pass where applicable
- state transition tests pass
- policy/permission tests pass
- forbidden-scope tests pass where applicable
- regression tests for known risks pass

For payment and fulfilment slices, tests must prove:

- duplicate webhook replay is safe
- callback verify success before webhook is safe
- webhook success before callback is safe
- pending/processing states do not fulfil
- contradictory provider status moves to review, not silent cancellation
- payment-review grants deny access
- fulfilment is idempotent

---

### Step 6 — Merge and tag

After implementation and tests pass:

```text
Merge the feature branch.
Tag the code and planning state.
Update the current baseline reference.
Move to the next slice.
```

Do not mix large planning changes and large code changes in one uncontrolled branch.

---

## 6. Recommended Repo Workflow

Keep planning and implementation work cleanly separated.

Example branch flow:

```text
main
  docs/planning/current = v0.2.7

branch: planning/v0.2.8-vs000-ready
  update planning docs only

branch: feature/vs000-tracer-bullet
  implement code only for VS-000

branch: planning/v0.2.9-vs001a-ready
  update planning docs only

branch: feature/vs001a-auth-registration
  implement code only for VS-001A
```

Suggested folder layout:

```text
/docs/planning/current/
  planning-pack.yml
  00-project-seed-brief.md
  04-domain-map.md
  05-resource-cards.md
  06-action-cards.md
  08-slice-matrix.md
  12-actor-permission-matrix.md
  13-state-transition-map.yml
  14-test-matrix.yml
  slices/
  tools/

/docs/planning/baselines/
  v0.2.7/
  v0.2.8/
  v0.2.9/
```

The current planning pack should always be easy for an agent to find.

---

## 7. When Expansion Happens

Expansion happens **between baselines**, not randomly during coding.

A future feature moves through this lifecycle:

```text
deferred
→ grilled
→ patched into planning baseline
→ marked active for a specific slice
→ implemented
→ tested
→ merged
```

A backend resource, action, or domain should become active only when:

```text
A locked slice requires it
```

or:

```text
A tracer bullet proves it is necessary
```

Do not add backend architecture just because it may be useful later.

---

## 8. Example: Auto-Renewing Subscriptions

In the current project direction, auto-renewing subscriptions are not allowed to leak into early membership purchase slices.

### Current v0.2.x scope

v0.2.x should prove:

```text
User can buy a first membership term.
Payment can be verified.
Membership can activate.
Access can be granted.
Payment method can be captured.
Auto-renewing plans are blocked from public sale until recurring capability exists.
```

### Current active/deferred distinction

```text
PaymentMethod = active
Subscription = deferred
```

The code may implement `PaymentMethod`.

The code may not implement `Subscription` yet.

The system may store Paystack authorization metadata for future recurring billing.

The system may not sell true auto-renewing plans until the subscription engine exists.

### Future v0.3 scope

Auto-renewing subscriptions should become a separate planning expansion.

Possible v0.3 work:

```text
/grill-me subscription engine
→ generate v0.3.0 planning pack
→ define active Subscription resource
→ define Paystack subscription creation
→ define Paystack plan-code mapping
→ define renewal invoice events
→ define charge.success handling for renewals
→ define invoice.payment_failed handling
→ define subscription.disable handling
→ define cancellation rules
→ define non-renewing state
→ define dunning/retry rules
→ define renewal access extension
→ build subscription tracer bullet
```

This is a full lifecycle, not a small add-on.

---

## 9. Guardrails for Coding Agents

Any coding agent working on this project must follow these rules.

### 9.1 Scope guardrails

```text
Do not implement future slices.
Do not implement deferred resources.
Do not implement enterprise features unless the selected slice explicitly requires them.
Do not implement a generic catalog unless the planning pack activates it.
Do not implement full subscriptions until the Subscription resource is active.
Do not implement refunds, proration, dunning, cancellation, discount calculation, events, LMS, community, or physical products unless activated by a slice.
```

### 9.2 Ash-specific guardrails

```text
Use Ash 3.x.
Model domain behaviour through explicit resources, actions, policies, validations, and changes.
Do not hide domain state transitions in controllers or LiveViews.
Do not place payment fulfilment logic in UI code.
Do not bypass Ash actions for state-changing domain operations unless the planning pack explicitly allows it.
```

### 9.3 Payment guardrails

```text
Paystack callback presence gives no value.
Callback Verify success may provisionally fulfil only through the same idempotent fulfilment action used by webhook processing.
Webhook remains authoritative.
Contradictory provider status moves the payment chain to payment_review.
Payment-review grants deny access.
Duplicate provider events must be idempotent no-ops.
Raw provider payloads must be stored only according to the planning pack's restricted/evidence rules.
```

### 9.4 Time and ID guardrails

```text
Use UUIDv7 for primary IDs.
Use UTC microsecond precision for persisted timestamps.
Do not use UUIDv7 order as business truth.
Use explicit timestamps and event metadata for business ordering.
```

---

## 10. Slice Readiness States

Use clear readiness states.

```text
DRAFT
  The slice exists but is not reviewed.

READY_FOR_REVIEW
  The slice has enough shape to grill.

READY_FOR_REVIEW_CLEAN
  The planning validator passes, but the slice is not implementation-ready.

READY_FOR_CODING
  The slice has passed grill review, has exact resources/actions/tests, and may be implemented.

IMPLEMENTED
  The slice has been coded and tests pass.

MERGED
  The slice has been merged into the main branch.
```

Important:

```text
Validator passed does not mean coding-ready.
```

The validator catches mechanical consistency.

The grill session catches semantic and implementation ambiguity.

---

## 11. Standard Agent Prompt: Slice Grill

Use this when asking an agent to grill a slice.

```text
You are acting as a ruthless software architecture reviewer and coding-agent safety reviewer.

Review only the selected slice: [SLICE-ID] from planning pack [VERSION].

Your job is not to improve writing style.

Your job is to expose anything that would cause a coding agent to:
- invent missing resources
- guess action behaviour
- create wrong Ash resources
- misunderstand tenancy or ownership
- mix read models and write models
- implement side effects in the wrong place
- skip tests
- ignore unresolved decisions
- build from vague workflows
- create bloated domains
- duplicate business truth
- implement deferred scope

Focus on:
1. Missing resource fields
2. Missing action contracts
3. Missing state transitions
4. Actor/permission contradictions
5. Payment or fulfilment ambiguity
6. Transaction boundary ambiguity
7. Idempotency gaps
8. Test gaps
9. Deferred features leaking into active scope
10. Anything that blocks coding readiness

Output:
- P0 blockers
- P1 required hardening
- P2 improvements
- Required patch decisions
- Final verdict: READY_FOR_CODING or NOT_READY
```

---

## 12. Standard Agent Prompt: Slice Implementation

Use this only after the selected slice has been patched and marked `READY_FOR_CODING`.

```text
You are implementing only [SLICE-ID] from planning pack [VERSION].

The planning pack is authority.

Rules:
- Implement only this slice.
- Do not implement future slices.
- Do not implement deferred resources.
- Do not add fields, actions, states, or policies unless required by this slice or explicitly required by the planning pack.
- If required implementation detail is missing, stop and report the gap instead of inventing.
- Use Ash 3.x patterns.
- Keep domain behaviour in Ash resources/actions/policies, not UI code.
- All primary IDs must use UUIDv7.
- All persisted timestamps must use UTC microsecond precision.
- UUIDv7 ordering may be used only as a secondary technical ordering aid, never as business truth.
- All tests listed for this slice must be implemented and pass.

Deliverables:
1. Code changes for [SLICE-ID]
2. Migrations if required
3. Tests required by the planning pack
4. Notes on any unresolved gaps
5. Confirmation that no deferred scope was implemented
```

---

## 13. Standard Agent Prompt: Planning Patch

Use this after a grill session when generating the next planning baseline.

```text
Generate planning pack [NEW_VERSION] from [OLD_VERSION].

Apply only the locked decisions from the latest grill session for [SLICE-ID].

Do not expand unrelated scope.
Do not activate deferred resources unless explicitly decided.
Do not rewrite the whole pack unnecessarily.
Preserve existing structure and semantics where possible.

Update:
- planning-pack.yml
- domain map
- resource cards
- action cards
- actor/permission matrix
- state-transition map
- test matrix
- slice files
- validator rules if needed
- changelog
- validation report

Only mark [SLICE-ID] READY_FOR_CODING if all P0 blockers are resolved and required implementation contracts are explicit.

Output a downloadable archive.
```

---

## 14. Practical Example Flow

Starting point:

```text
Current baseline: v0.2.7
coding_status: NOT_READY
```

Next move:

```text
/grill-me VS-000 against v0.2.7
```

Then:

```text
Generate v0.2.8
Mark only VS-000 READY_FOR_CODING
```

Then:

```text
Implement VS-000 backend tracer bullet
Run all VS-000 tests
Merge
```

Then:

```text
/grill-me VS-001A against latest baseline
Generate v0.2.9
Implement VS-001A
Run tests
Merge
```

Then repeat.

---

## 15. Summary

The workflow is:

```text
Plan narrowly
Grill aggressively
Patch precisely
Build only what is required
Test as proof
Merge cleanly
Expand only when a locked slice requires it
Repeat
```

This creates a system where:

- planning drives implementation
- tests verify the law
- agents cannot safely invent missing behaviour
- deferred features stay deferred
- backend foundation expands only when justified
- vertical slices become real, testable product capabilities

The final rule:

```text
No slice becomes code until it has become law.
No future feature becomes law until it has survived the grill.
```
