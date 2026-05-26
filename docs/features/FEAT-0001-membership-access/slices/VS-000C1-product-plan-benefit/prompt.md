# Coding Prompt — VS-000C1

Implement VS-000C1 only.

## Authority

- `AGENTS.md`
- `docs/features/FEAT-0001-membership-access/**`
- current code on `main`

## Goal

Add the Memberships setup resources:

- `VgApp.Memberships.MembershipProduct`
- `VgApp.Memberships.MembershipPlan`
- `VgApp.Memberships.BenefitRule`

## Allowed

- Ash resources/actions/policies/migrations/snapshots/tests for MembershipProduct, MembershipPlan, BenefitRule.
- Domain actions:
  - `Memberships.create_membership_product`
  - `Memberships.activate_membership_product`
  - `Memberships.create_membership_plan`
  - `Memberships.activate_membership_plan`
  - `Memberships.create_benefit_rule`
  - `Memberships.activate_benefit_rule`
- `:system` and `staff_admin` setup authorization.
- Monthly/yearly/lifetime schema and tests.
- `auto_renewing` modelled but blocked from live/public activation.
- `vriendinneklub_discount_access` as eligibility only.

## Forbidden

- Membership resource
- EntitlementGrant resource
- access evaluation
- Catalog
- Commerce
- Paystack
- UI
- discount calculation

## Required tests

- creates membership product with unique code
- rejects duplicate product code
- creates monthly, yearly, and lifetime plans
- rejects invalid duration configuration
- duplicate plan code rejected
- auto_renewing plan cannot go live without recurring capability
- benefit rule can activate for draft or active non-archived plan
- active plan requires active product and at least one active benefit rule
- discount benefit does not calculate discount

## Required checks

```bash
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

Open PR:

```text
VS-000C1: Membership product, plan, and benefit foundation
```
