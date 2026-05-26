# 07 — Slice Plan

## VS-000C0 — Hygiene/auth hardening

Status: optional but recommended before C1 if not already completed.

Scope:

- normalize script line endings if needed
- fix `make status` if broken
- harden `AccountRole` broad read policy if still present
- no Memberships resources

PR title:

```text
VS-000C0: Hygiene and auth hardening
```

## VS-000C1 — Product, plan, and benefit foundation

Scope:

- MembershipProduct
- MembershipPlan
- BenefitRule
- setup actions
- tests for duration config and activation rules

Forbidden:

- Membership
- EntitlementGrant
- access evaluation
- Catalog
- Commerce
- Paystack

PR title:

```text
VS-000C1: Membership product, plan, and benefit foundation
```

## VS-000C2 — Membership lifecycle

Scope:

- Membership
- pending membership creation
- system-only activation
- duration snapshotting
- expiry calculation
- active membership uniqueness
- activation idempotency

Forbidden:

- EntitlementGrant access evaluation unless only prepared by types/relationships needed
- Catalog
- Commerce
- Paystack

PR title:

```text
VS-000C2: Membership lifecycle foundation
```

## VS-000C3 — Entitlement grants and access evaluation

Scope:

- EntitlementGrant
- grant creation
- access evaluation
- idempotent grant creation
- defensive access denial tests

Forbidden:

- Catalog
- Commerce
- Paystack
- UI
- discount calculation

PR title:

```text
VS-000C3: Entitlement grants and access evaluation
```
