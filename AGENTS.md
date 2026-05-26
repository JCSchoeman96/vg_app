# AGENTS.md — vg_app Coding Agent Law

> Purpose: instructions for coding agents working inside this repo.
> Planning, grill-me sessions, Linear creation, feature-pack authoring, and PR approval are handled by the ChatGPT project, not by the coding agent.

## 0. Role Boundary

Coding agents SHALL:
- inspect the current repo
- implement only the assigned Linear issue / slice / prompt
- write or update tests
- use Ash codegen for Ash resource changes
- update code documentation
- update the implementation ledger when the assigned slice merges or when explicitly instructed
- open a PR with clear verification notes

Coding agents SHALL NOT:
- run feature grill-me sessions
- create or change business scope
- create Linear issues
- invent resources/actions/policies not in the assigned prompt or feature pack
- implement future slices
- approve or merge PRs
- weaken tests to pass

If planning is missing or contradictory, STOP and report `BLOCKED`.

## 1. Source of Truth

Order of authority:

1. Merged code on `main`
2. This `AGENTS.md`
3. Assigned Linear issue / assigned coding prompt
4. Repo feature pack under `docs/features/**`
5. `docs/planning/current/**`
6. PR body / chat summary

If sources conflict, STOP and report the conflict.

## 2. Stack Law

```text
App        |> vg_app
Language   |> Elixir
Framework  |> Phoenix
Domain     |> Ash 3.x
Database   |> PostgreSQL + AshPostgres
Jobs       |> Oban
HTTP       |> Bandit
CSS        |> Tailwind
IDs        |> UUIDv7
Time       |> UTC microsecond precision
Tools      |> mise, make, gh, rg, ast-grep
```

All new code SHALL follow this stack unless the assigned prompt explicitly says otherwise.

## 3. Normal Execution Pattern

```text
read AGENTS.md
|> inspect assigned issue/prompt
|> inspect relevant repo docs and code
|> make status
|> make doctor
|> make sync-check
|> search with rg / ast-grep
|> write RED tests
|> implement minimum GREEN code
|> run checks
|> update docs/ledger if assigned
|> commit
|> open PR
```

Do not start from stale assumptions. Inspect the repo first.

## 4. Scope Discipline

One issue/slice SHOULD produce one PR.

Coding agents MUST NOT:
- mix unrelated slices
- implement deferred features
- build speculative abstractions
- add UI unless the slice explicitly requires UI
- bypass Ash domain actions for business flows
- add dependencies without explicit approval
- use raw DB operations for domain behaviour unless explicitly test-fixture only

## 5. Search and Reuse

Before creating a module, function, helper, policy, migration, or test pattern:

```bash
rg "term|similar_name|existing_name" lib test config docs
ast-grep --pattern '<pattern>' lib test || true
```

Reuse existing functions where safe. Do not create duplicate helper modules or dumping-ground utility files.

## 6. Ash Rules

Ash resources/actions/policies are the business boundary.

Coding agents SHALL:
- use Ash resources for domain truth
- define explicit actions for behaviour
- define policies for actor access
- use AshPostgres codegen for migrations/snapshots
- run Ash drift checks before PR

Coding agents SHALL NOT:
- put domain truth in LiveViews/controllers
- mutate business records by bypassing Ash actions
- hand-edit generated snapshots unless explicitly required and justified

## 7. Test Law

Use RED -> GREEN -> REFACTOR.

Forbidden:
- removing assertions to pass
- weakening precise tests into vague tests
- skipping failing tests
- mocking away core domain behaviour
- hiding failures behind broad matches

Every behaviour change SHALL have tests.

## 8. Documentation Law

Important public modules SHOULD have:

```elixir
@moduledoc
```

Important public functions SHOULD have:

```elixir
@doc
@spec
```

Comments explain **why**, not obvious code mechanics.

After a slice merges, or when explicitly instructed, update the relevant:

```text
docs/features/<feature>/implementation-ledger.md
```

Ledger entries SHOULD include:
- slice name
- PR number
- merge commit
- resources/actions/policies changed
- migrations/snapshots
- important files
- tests added
- commands run
- deferred work and risks

The ledger does not replace `@moduledoc`, `@doc`, or `@spec`.

## 9. Required Commands

Use repo automation first.

Before work:
```bash
make status
make doctor
make sync-check
```

Before PR:
```bash
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

When available/relevant:
```bash
mix format --check-formatted
mix credo --strict
mix sobelow --exit
mix deps.audit
make precommit
```

If a Makefile/script target is broken, report it. Do not silently bypass repo automation.

## 10. Git and PR Rules (gh CLI is available and MUST be used)

Branch names SHOULD follow:

```text
feature/<slice>-<short-name>
fix/<short-description>
chore/<short-description>
docs/<short-description>
```

Every PR SHALL include:
- issue/slice ID
- what changed
- what is not included
- tests added/updated
- commands run
- known gaps/deferred items

Default PR body:

```markdown
## Issue / Slice

## Changes

## Not Included

## Tests

## Commands Run

## Deferred / Known Gaps
```

Coding agents open PRs. They do not approve or merge them.

## 11. Stop Conditions

STOP and report `BLOCKED` when:
- assigned prompt conflicts with repo docs/code
- resource/action/policy is missing or unclear
- state transition is unclear
- test expectation conflicts with planning
- auth/security/payment implication is unclear
- dependency/version is unknown
- precommit/checks fail after reasonable fix attempts
- repo has merge/rebase/conflict state

Blocker report format:

```text
BLOCKED
missing rule:
affected files:
risk:
recommended options:
```

## 12. Absolute Forbidden Behaviour

Coding agents MUST NOT:
- invent business rules
- implement future scope
- weaken tests
- skip required checks
- commit secrets
- mix unrelated work
- hide failures
- bypass Ash domains
- put domain truth in UI
- approve or merge PRs
