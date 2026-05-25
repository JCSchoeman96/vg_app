# AGENTS.md

> Operating law for `vg_app` coding agents, review agents, and planning agents.
> Keep this file short, strict, and executable.

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

Agents SHALL implement only the assigned tracer bullet or vertical slice.
Agents SHALL NOT implement deferred resources, future slices, or speculative abstractions.
Agents SHALL stop and report gaps instead of inventing missing business rules.

---

## 1. Stack

```text
App name       |> vg_app
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
Tool runner    |> mise
GitHub         |> gh CLI
```

All new code SHALL respect this stack unless the active planning pack explicitly overrides it.

---

## 2. End Goal

```text
vg_app
|> controlled membership-commerce foundation
|> multi-product memberships
|> Paystack-first payment verification
|> entitlement-based access
|> future auto-renewing subscriptions
|> Phoenix/Ash architecture
|> no hidden business logic
|> no scope creep
```

The platform SHALL grow through locked tracer bullets and vertical slices only.

---

## 3. Assertion Language

```text
SHALL      |> mandatory implementation rule
MUST       |> mandatory process/safety rule
MUST NOT   |> forbidden action
MAY        |> allowed, not required
SHOULD     |> recommended default
DEFERRED   |> documented, not implementable now
BLOCKED    |> cannot proceed until resolved
```

Agents MUST preserve assertion language in docs, tests, PR notes, and review comments.

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

Agents MUST NOT build the full baseline at once.
Agents MUST NOT build frontend before backend rules and tests exist unless the slice explicitly requires it.

---

## 5. Tracer Bullets and Vertical Slices

```text
Tracer Bullet
|> proves architecture path
|> may be backend/tests only
|> exposes missing resource/action/state law
|> does not require polished UI
```

```text
Vertical Slice
|> delivers one user/business capability
|> includes only required backend + UI + tests
|> is independently reviewable
|> must not absorb future features
```

```text
Future capability
|> DEFERRED until grilled
|> ACTIVE only after planning patch
|> IMPLEMENTED only inside assigned slice
```

---

## 6. Repo Automation Authority

Agents SHALL use repo automation before ad-hoc commands.

```text
Makefile          |> primary command surface
scripts/          |> repeatable repo operations
.githooks/        |> local Git hooks
.tool-versions    |> pinned runtime/tooling versions
mix.exs           |> Elixir dependencies/tasks
assets/package.*  |> frontend dependencies
```

Required files:

```text
Makefile
scripts/check_repo_state.sh
scripts/create_pr.sh
scripts/dev_postgres.sh
scripts/install_git_hooks.sh
scripts/precommit.sh
scripts/sync_with_origin_main.sh
.githooks/pre-commit
```

Scripts SHALL be executable.
Agents SHALL NOT bypass existing Makefile targets or scripts unless the target is broken and the failure is reported.

---

## 7. Makefile Law

Default target SHALL be safe:

```text
make             |> help only
```

Canonical targets:

```text
make status          |> git branch/status/worktrees
make doctor          |> required local tool check
make sync-check      |> safe Git sync check
make sync            |> safe origin/main sync
make toolchain       |> mise install + BEAM verification
make deps            |> Hex/Rebar/deps compile
make hooks           |> install repo-local hooks
make infra           |> start local Postgres
make db              |> prepare dev database
make db-test         |> prepare test database
make setup           |> doctor + toolchain + deps + hooks + infra + dbs
make ready           |> status + sync + setup + ci
make ready-local     |> status + setup + ci, no git sync
make check           |> format-check + compile + test
make precommit       |> full local gate
make ci              |> CI-equivalent local gate
make pr              |> check/push/create PR through gh
```

Ash targets:

```text
make ash-codegen-dev
make ash-codegen NAME=<meaningful_name>
make ash-migrate
```

Database targets:

```text
make reset-db        |> destructive; requires script-level --yes
make stop-db
make logs-db
make psql-db
```

Agents SHALL prefer:

```text
make status
|> make doctor
|> make sync-check
|> work
|> make check
|> make precommit
|> make pr
```

---

## 8. Required Tools

`make doctor` SHALL fail if required tools are missing.

```text
git        |> source control
bash       |> scripts
make       |> command orchestration
mise       |> toolchain runner
docker     |> local Postgres
gh         |> PR creation
rg         |> repository search
ast-grep   |> structural search/refactor checks
```

`ast-grep` command MAY be available as `ast-grep` or `sg`.

---

## 9. Git and PR Rules

Before edits:

```text
make status
|> make sync-check
```

Branch naming:

```text
planning/vX.Y.Z-<slice>-ready
feature/<slice>-<short-name>
fix/<short-description>
chore/<short-description>
```

Meaningful work SHALL end with a PR:

```text
make precommit
|> git status --short --branch
|> commit
|> make pr
```

`gh` CLI SHALL be used for PRs.

Agents MUST NOT:

```text
commit secrets
rewrite shared history without approval
mix unrelated slices in one PR
rebase a pushed/shared branch without approval
continue during merge/rebase/cherry-pick conflict state
```

---

## 10. Search Before Code

Agents MUST search before creating modules, functions, helpers, policies, or tests.

```text
rg / grep   |> text search
ast-grep    |> structural code search
mix xref    |> dependency/call checks when relevant
```

Minimum before new function/module:

```bash
rg "domain_term|similar_name|existing_name" lib test config
ast-grep --pattern '<pattern>' lib test || true
```

Reuse law:

```text
existing function fits
|> reuse it
existing function almost fits
|> extend safely if slice allows
no existing function fits
|> create new function with RED tests
```

Agents MUST NOT create duplicate helpers when existing code can be reused safely.

---

## 11. Local Postgres Law

Local Postgres automation SHALL use `scripts/dev_postgres.sh` through Makefile targets.

```text
container |> vg_app-postgres-dev
volume    |> vg_app-postgres-dev-data
database  |> vg_app_dev
image     |> postgres:16-alpine
host port |> 5433 by default
```

Use:

```text
make infra
make db
make db-test
make reset-db
make stop-db
make logs-db
make psql-db
```

Agents MUST NOT hardcode local Postgres assumptions in application code.
Environment/config files SHALL define app DB connection details.

---

## 12. Precommit Gate

`make precommit` SHALL run before PR.

Current gate:

```text
mix format --check-formatted
|> mix compile --warnings-as-errors
|> mix ash.codegen --check
|> mix credo --strict
|> mix sobelow --config
|> MIX_ENV=test mix test
|> mix dialyzer
```

The gate is executed by:

```text
scripts/precommit.sh
.githooks/pre-commit
```

`ASH_CODEGEN_CHECK_CMD` MAY override the Ash codegen drift command if project convention changes.
`SOBELOW_CMD` MAY override Sobelow config invocation if project convention changes.

Agents MUST NOT weaken `scripts/precommit.sh` to make tests green.
Agents MUST report gate failures honestly with command summaries.

---

## 13. Test Law

```text
RED test
|> write failing test first
|> prove failure is meaningful

GREEN test
|> implement minimum correct code
|> pass without weakening assertions

REFACTOR
|> only after GREEN
|> keep tests GREEN
```

Agents SHALL write or update tests for every meaningful behaviour change.

Forbidden:

```text
skip test to pass
remove assertion to pass
rewrite precise test into vague test
mock away core domain behaviour
hide failure behind broad match
```

Allowed only when planning law requires it:

```text
test was wrong
|> explain why
|> replace with stronger accurate assertion
|> cite planning rule in PR
```

---

## 14. Ash / Domain Rules

```text
Ash resource      |> domain truth boundary
Ash action        |> explicit behaviour contract
Ash policy        |> actor permission boundary
Changeset         |> validation/change boundary
Oban job          |> async boundary only
Phoenix LiveView  |> UI boundary only
Controller        |> transport boundary only
```

Agents SHALL NOT place domain truth in LiveView/controllers.
Agents SHALL NOT bypass Ash actions for domain mutations unless the active planning pack explicitly allows it.
Agents SHALL use AshPostgres migrations/codegen according to project convention.

---

## 15. Payment / Membership Safety

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
|> reconciliation required
```

Agents SHALL NOT duplicate fulfilment logic between callback and webhook paths.
Agents SHALL NOT activate access from unverified client-side data.
Agents SHALL NOT implement auto-renewing subscriptions until active planning law exists.

---

## 16. IDs and Time

```text
Primary keys      |> UUIDv7
UUID ordering     |> secondary technical ordering aid only
Business order    |> explicit timestamp / sequence / provider metadata
Timestamps        |> UTC microsecond precision
Local time        |> presentation only unless domain rule says otherwise
```

Agents SHALL NOT use UUID order as authoritative business event order.
Agents SHALL NOT store naive local timestamps for persisted domain facts.

---

## 17. Docs, Specs, and Comments

Public modules SHOULD include:

```elixir
@moduledoc
```

Public functions SHOULD include:

```elixir
@doc
@spec
```

Comments SHALL explain why, not restate what.

```text
Good comment |> invariant, trade-off, domain rule
Bad comment  |> repeats function name in prose
```

---

## 18. Reuse and Abstraction Law

```text
search existing
|> inspect similar modules
|> reuse if compatible
|> extend if safe
|> create only if necessary
```

Agents MUST prefer small composable functions.
Agents MUST NOT create helper dumping grounds.
Agents MUST NOT introduce abstractions for future features unless the active slice requires them.

---

## 19. PR Requirements

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
## Slice / Tracer Bullet

## Planning Baseline

## Changes

## Not Included

## Tests

## Commands Run

## Deferred / Known Gaps
```

Use:

```text
make pr
```

or, only if the script is unavailable:

```bash
gh pr create --fill
```

---

## 20. Stop Conditions

Agents MUST stop and report when:

```text
planning law missing
actor permission unclear
state transition unclear
resource/action card absent
test expectation conflicts with planning pack
payment/security implication unclear
required dependency/version unknown
precommit gate fails after reasonable fix attempt
repo automation target is broken
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

## 21. Forbidden Behaviour

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
ignore Makefile/scripts
implement auto-renewing subscriptions before active planning law exists
```

---

## 22. Default Execution Pattern

```text
read AGENTS.md
|> read current planning pack
|> identify assigned slice
|> make status
|> make doctor
|> make sync-check
|> search existing code with rg + ast-grep
|> write RED tests
|> implement minimum code
|> make check
|> make precommit
|> commit
|> make pr
|> report exact status
```
