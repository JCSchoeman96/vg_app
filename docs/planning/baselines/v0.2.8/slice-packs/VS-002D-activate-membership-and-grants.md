# VS-002D — Activate Membership and Entitlement Grants

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `Order`
- `OrderItem`
- `Membership`
- `BenefitRule`
- `EntitlementGrant`

## Actions involved
- `Memberships.activate_membership`
- `Memberships.create_entitlement_grants`

## Blocking decisions
- none

## Required tests
- `membership_snapshots_duration_terms`
- `lifetime_membership_has_no_expiry`
- `fixed_period_membership_sets_expires_at`
- `benefit_rule_creates_expected_grants`
- `grant_validity_matches_membership_validity`
- `payment_review_grant_blocks_access`

## Slice law
VS-002D SHALL provide the membership activation/grant primitives used by `Commerce.fulfil_paid_order`.

Activation and grant creation SHALL commit or roll back together.

`Memberships.activate_membership` and `Memberships.create_entitlement_grants` SHALL NOT independently decide payment truth. Payment truth comes from Commerce evidence and fulfilment orchestration.
