# VS-002E — Evaluate Member Access

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `Membership`
- `EntitlementGrant`

## Actions involved
- `Memberships.evaluate_entitlement_access`
- `Memberships.expire_due_memberships`

## Blocking decisions
- none

## Required tests
- `access_evaluation_does_not_mutate_state`
- `expired_grant_blocks_access`
- `cancelled_membership_blocks_access`
- `expire_due_memberships_marks_expired`

## Slice law
Access evaluation SHALL be read-only and system-mediated through the application boundary.

It SHALL deny access if Membership or EntitlementGrant is expired by state or date, even if the scheduled expiry job has not yet run.
