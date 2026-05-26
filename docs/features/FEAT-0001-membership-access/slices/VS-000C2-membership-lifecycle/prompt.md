# Coding Prompt — VS-000C2

Implement VS-000C2 only.

## Goal

Add `VgApp.Memberships.Membership` and lifecycle actions.

## Allowed

- Membership resource/actions/policies/migrations/snapshots/tests.
- `Memberships.create_pending_membership`
- `Memberships.activate_membership`
- system-only activation
- duration snapshotting
- expiry calculation for monthly/yearly/lifetime
- nullable `activation_order_id`
- one active membership per user/product DB invariant where feasible
- multiple pending memberships
- idempotent activation

## Forbidden

- EntitlementGrant
- access evaluation
- Catalog
- Commerce
- Paystack
- UI
- cancellation action

## Required tests

- creates pending membership
- pending membership does not grant access or imply access
- fixed-period monthly membership sets expires_at
- yearly membership sets expires_at
- lifetime membership has no expiry
- Jan 31 monthly expiry clamps to Feb 28/29
- blocks second active membership per product
- allows multiple pending memberships
- second activation returns/reuses existing active membership

## Required checks

```bash
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

Open PR:

```text
VS-000C2: Membership lifecycle foundation
```
