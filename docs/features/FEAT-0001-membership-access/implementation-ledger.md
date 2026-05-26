# Implementation Ledger — FEAT-0001 Membership Access Foundation

This ledger records what was actually implemented after each slice merges.

It does not replace `@moduledoc`, `@doc`, or `@spec`.

---

## VS-000A — Domain shells and planning baseline

Status: Done  
PR: #3  
Summary:

- Added domain shells for Memberships, Catalog, and Commerce.
- Wired domains into Ash domain configuration.
- Extracted v0.2.8 planning baseline/current docs into repo.
- Added lightweight tracer skeleton test.

Key files:

- `lib/vg_app/memberships.ex`
- `lib/vg_app/catalog.ex`
- `lib/vg_app/commerce.ex`
- `docs/planning/current/**`
- `docs/planning/baselines/v0.2.8/**`

Deferred:

- Real resources/actions deferred to later micro-slices.

---

## VS-000B — Accounts foundation

Status: Done  
PR: #4  
Summary:

- Added `UserProfile`, `ConsentRecord`, `AccountRole`.
- Extended `User` with UUIDv7 primary key and state.
- Added `Accounts.register_user/1` using AshAuthentication `register_with_password`, profile creation, and consent creation in one transaction.
- Added staff_admin role foundation and system-only bootstrap.

Key files:

- `lib/vg_app/accounts.ex`
- `lib/vg_app/accounts/user.ex`
- `lib/vg_app/accounts/user_profile.ex`
- `lib/vg_app/accounts/consent_record.ex`
- `lib/vg_app/accounts/account_role.ex`
- `lib/vg_app/accounts/checks/staff_admin.ex`
- `lib/vg_app/accounts/checks/system_actor.ex`
- `lib/vg_app/accounts/changes/set_granted_at_now.ex`
- `test/vg_app/accounts/register_user_test.exs`

Tests added:

- registration creates user/profile/required consents
- duplicate email rejection
- rollback prevents orphan user
- marketing consent version required when marketing consent is true
- staff_admin role required for role assignment
- granted_at set at execution time

Deferred:

- role revocation
- broader auth/admin hardening

---

## VS-000C0 — Hygiene/auth hardening

Status: Not started  
PR: TBD

## VS-000C1 — Product, plan, and benefit foundation

Status: Not started  
PR: TBD

## VS-000C2 — Membership lifecycle

Status: Not started  
PR: TBD

## VS-000C3 — Entitlement grants and access evaluation

Status: Not started  
PR: TBD
