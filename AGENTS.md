# AGENTS.md

> Agent operating law for this repository.  
> This file is authority for coding agents, review agents, and planning agents.

---

## 0. Prime Directive

```text
Planning Pack = law
Vertical Slice = work order
Tracer Bullet = proof path
Tests = court
Code = implementation
PR = review boundary
```

Agents SHALL implement only the active slice or tracer bullet assigned.
Agents SHALL NOT implement deferred resources, future slices, or speculative abstractions.
Agents SHALL stop and report gaps instead of inventing missing business rules.

---

## 1. Stack

```text
Language       |> Elixir
Framework      |> Phoenix
Domain         |> Ash 3.x
Database       |> PostgreSQL + AshPostgres
Jobs           |> Oban
HTTP           |> Bandit
CSS            |> Tailwind CSS
UI             |> DaisyUI
Components     |> Mishka Chelekom
IDs            |> UUIDv7
Timestamps     |> UTC microsecond precision
```

All new code SHALL respect this stack unless the planning pack explicitly overrides it.

---

## 2. End Goal

```text
Build a controlled membership-commerce platform
|> multi-product membership foundation
|> Paystack-first payment verification
|> entitlement-based access
|> future auto-renewing subscriptions
|> expandable Phoenix/Ash architecture
|> no scope creep
|> no hidden business logic
```

The platform SHALL grow by locked tracer bullets and vertical slices only.

---

## 3. Assertion Language

Use these words precisely:

```text
SHALL      |> mandatory implementation rule
MUST       |> mandatory process/safety rule
MUST NOT   |> forbidden action
MAY        |> allowed, not required
SHOULD     |> recommended default
DEFERRED   |> documented but not implementable now
BLOCKED    |> cannot proceed until resolved
```

Agents MUST preserve assertion language in docs, comments, tests, and PR notes.

---

## 4. Development Flow

```text
latest planning baseline
|> choose one tracer bullet or vertical slice
|> grill the slice
|> patch planning pack
|> mark only that slice READY_FOR_CODING
|> create branch
|> write RED tests
|> implement minimum code
|> make tests GREEN
|> run precommit gate
|> create PR
|> review
|> merge
|> repeat
```

Agents MUST NOT build the whole baseline at once.
Agents MUST NOT build frontend before backend rules and tests exist unless the slice explicitly requires it.

---

## 5. Tracer Bullets and Vertical Slices

### Tracer Bullet

```text
Tracer Bullet
|> proves architecture path
|> may be backend/tests only
|> exposes missing resource/action/state law
|> does not require polished UI
```

### Vertical Slice

```text
Vertical Slice
|> delivers a user/business capability
|> includes only required backend + UI + tests
|> must be independently reviewable
|> must not absorb future features
```

### Rule

```text
Future capability
|> DEFERRED until grilled
|> ACTIVE only after planning patch
|> IMPLEMENTED only inside assigned slice
```

---

## 6. Repo Rules

```text
git status       |> check before work
git branch       |> confirm branch before work
git worktree     |> inspect when relevant
gh CLI           |> available and SHALL be used for PRs
meaningful work  |> SHALL end with a PR
```

Before edits:

```bash
git status --short
git branch --show-current
git worktree list
```

Branch naming:

```text
planning/vX.Y.Z-<slice>-ready
feature/<slice>-<short-name>
fix/<short-description>
chore/<short-description>
```

PR rule:

```text
Meaningful code/doc change
|> commit
|> push branch
|> gh pr create
```

Agents SHALL NOT commit secrets.
Agents SHALL NOT rewrite history unless explicitly instructed.
Agents SHALL NOT mix unrelated slices in one PR.

---

## 7. Required Search and Analysis Tools

Agents MUST use repository search before creating new code.

```text
rg / grep   |> required for text search
ast-grep    |> required for structural code search/refactor checks
mix xref    |> use for dependency/call checks when relevant
```

Required before adding a new function/module:

```bash
rg "existing_name|similar_term|domain_term" lib test config
ast-grep --pattern '<pattern>' lib test
```

Rule:

```text
Existing function fits
|> reuse it
Existing function almost fits
|> extend safely if slice allows
No existing function fits
|> create new function with tests
```

Agents MUST NOT create unnecessary duplicate helpers.

---

## 8. Scripts and Mix Tasks From the Start

The repo SHOULD include scripts and Mix tasks for repeatable checks.

Required script intent:

```text
scripts/project_status.sh        |> git status, branch, worktrees, Elixir/Phoenix versions
scripts/precommit.sh             |> full local quality gate
scripts/ensure_clean_tree.sh     |> fail if unexpected dirty tree
scripts/verify_planning_pack.sh  |> validate planning docs when present
```

Required Mix task intent:

```text
mix vgo.doctor          |> project health checks
mix vgo.repo_status     |> repo state summary
mix vgo.validate_plan   |> planning pack validation
mix vgo.quality         |> compile + format + credo + tests + sobelow + dialyzer
```

If a script/task does not exist yet, the first relevant slice SHOULD add it.

---

## 9. Makefile

A `Makefile` SHALL exist and expose stable commands.

Minimum targets:

```makefile
setup:
status:
doctor:
compile:
format:
credo:
dialyzer:
sobelow:
test:
test-red:
test-green:
ash-codegen:
precommit:
ci:
pr:
```

Canonical pipeline:

```text
make status
|> make test-red
|> implement
|> make test-green
|> make precommit
|> make pr
```

Agents SHALL prefer Make targets over ad-hoc commands once targets exist.

---

## 10. Precommit Gate

`precommit` SHALL always run before PR.

Minimum gate:

```text
mix deps.unlock --check-unused
|> mix compile --warnings-as-errors
|> mix format --check-formatted
|> mix ash.codegen --check
|> mix test
|> mix credo --strict
|> mix sobelow --config
|> mix dialyzer
```

If the project later uses `pre-commit`, the hook SHALL call the same gate.

Agents MUST NOT skip a failing gate.
Agents MUST report failures honestly with command output summary.

---

## 11. Test Law

```text
RED test   |> write failing test first
GREEN test |> implement minimum code to pass
REFACTOR   |> only after green
```

Agents SHALL write tests for every meaningful behaviour change.
Agents MUST NOT weaken, delete, skip, or rewrite tests merely to make the suite green.
Agents MUST NOT replace a precise test with a weaker test.

Allowed test changes:

```text
Test was wrong against planning law
|> explain
|> update with stronger/accurate assertion
|> cite planning rule in PR
```

Forbidden:

```text
skip test to pass
remove assertion to pass
mock away core domain behaviour
hide failure behind broad match
```

---

## 12. Ash / Domain Rules

```text
Ash resource      |> domain truth boundary
Ash action        |> explicit behaviour contract
Policy            |> actor permission boundary
Changeset         |> validation/change boundary
Oban job          |> async boundary only
Phoenix LiveView  |> UI boundary only
```

Agents SHALL NOT place domain truth in LiveView.
Agents SHALL NOT place payment fulfilment truth in controllers.
Agents SHALL NOT bypass Ash actions for domain mutations unless the planning pack explicitly allows it.
Agents SHALL use AshPostgres migrations/codegen according to project convention.

---

## 13. Payment / Membership Safety

```text
Paystack callback visit
|> no value by itself

Paystack Verify success
|> MAY provisionally fulfil through shared idempotent fulfilment action

Paystack webhook
|> authoritative payment event source

Contradiction
|> payment_review
|> block access
|> require reconciliation path
```

Agents SHALL NOT duplicate fulfilment logic between callback and webhook paths.
Agents SHALL NOT activate access from unverified client-side data.

---

## 14. IDs and Time

```text
Primary keys      |> UUIDv7
Ordering aid      |> UUIDv7 lexicographic order MAY be secondary only
Business order    |> explicit timestamp / sequence / provider metadata
Timestamps        |> UTC microsecond precision
Local time        |> presentation only unless domain rule says otherwise
```

Agents SHALL NOT use UUID order as authoritative business event order.
Agents SHALL NOT store naive local timestamps for persisted domain facts.

---

## 15. Docs, Specs, and Comments

Every public module SHOULD include:

```elixir
@moduledoc
```

Every public function SHOULD include:

```elixir
@doc
@spec
```

Private helpers SHOULD have clear names and tests through public behaviour.

Comments SHALL explain why, not restate what.

```text
Good comment |> explains invariant, trade-off, or domain rule
Bad comment  |> repeats the function name in prose
```

---

## 16. Reuse Law

Before creating new code:

```text
search existing
|> inspect similar modules
|> reuse if compatible
|> extend if safe
|> create only if necessary
```

Agents MUST prefer small composable functions.
Agents MUST NOT create helper modules as dumping grounds.
Agents MUST NOT introduce abstractions for future features unless active slice requires them.

---

## 17. PR Requirements

Every PR SHALL include:

```text
Slice / tracer bullet ID
Planning baseline version
What changed
What did not change
Tests added/updated
Commands run
Known gaps / deferred items
```

PR body template:

```markdown
## Slice

## Planning Baseline

## Changes

## Not Included

## Tests

## Commands Run

## Deferred / Known Gaps
```

Use:

```bash
gh pr create --fill
```

Then edit the PR body if needed.

---

## 18. Stop Conditions

Agents MUST stop and report when:

```text
planning law missing
actor permission unclear
state transition unclear
resource/action card absent
test expectation conflicts with planning pack
security/payment implication unclear
required dependency/version unknown
precommit gate fails after reasonable fix attempt
```

Report format:

```text
BLOCKED
|> missing rule:
|> affected files:
|> risk:
|> proposed decision options:
```

---

## 19. Forbidden Behaviour

Agents MUST NOT:

```text
build deferred features
invent business rules
weaken tests
skip precommit
commit secrets
mix unrelated slices
hide failures
bypass Ash domains
put domain truth in UI
implement auto-renewing subscriptions before active planning law exists
```

---

## 20. Default Execution Pattern

```text
read AGENTS.md
|> read current planning pack
|> identify assigned slice
|> check repo status
|> search existing code with rg + ast-grep
|> write RED tests
|> implement minimum code
|> run GREEN tests
|> run full precommit
|> create PR with gh
|> report exact status
```

