# FEAT-0001 — Membership Access Foundation

Status: `LOCKED_FOR_SLICE_PLANNING`

## Purpose

This feature pack captures the locked planning and backend decisions for the first Memberships implementation in `vg_app`.

It covers the VS-000C Memberships/access foundation that follows:

- VS-000A — Domain shells and planning baseline
- VS-000B — Accounts foundation

## Authority

This pack is repo-native planning context for coding agents. It SHALL be used together with:

1. merged code on `main`
2. `AGENTS.md`
3. assigned Linear issue / coding prompt
4. `docs/planning/current/**`

If this pack conflicts with current code on `main`, stop and update the pack before coding.

## Feature outcome

The system SHALL support a production-shaped membership/access foundation:

```text
MembershipProduct
|> MembershipPlan
|> BenefitRule
|> Membership
|> EntitlementGrant
|> evaluate_entitlement_access
```

The feature SHALL prove entitlement-based access without introducing Catalog, Commerce, Paystack, UI, or discount calculation.

## Micro-slices

```text
VS-000C0 |> Hygiene/auth hardening, if needed
VS-000C1 |> MembershipProduct, MembershipPlan, BenefitRule
VS-000C2 |> Membership lifecycle
VS-000C3 |> EntitlementGrant and access evaluation
```

Each micro-slice SHALL be independently mergeable and green.
