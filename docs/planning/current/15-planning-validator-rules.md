# 15. Planning Validator Rules

The executable validator in `tools/validate_planning_pack.py` SHALL check structural and selected semantic hazards.

## Required v0.2.8 checks

- planning pack YAML parses.
- all YAML fences parse.
- all resources in `planning-pack.yml` have resource cards.
- all actions referenced by resources and slices have action cards.
- all action tests appear in `14-test-matrix.yml`.
- all resource cards have field schemas.
- all field schema rows have `name`, `type`, `required`, and `nullable`.
- all action cards have accepted arguments, returns, errors, and mutation metadata.
- action actor matches `12-actor-permission-matrix.md`.
- AshAuthentication boundary is explicit.
- email confirmation is required before purchase.
- `MembershipProduct` exists and is not a generic catalog.
- `MembershipPlan` supports monthly/yearly/lifetime configuration.
- `Membership` snapshots duration terms and supports expiry.
- `EntitlementGrant` has validity dates.
- Paystack callback never delivers value.
- PaymentEvent owns idempotency.
- `recurring_ready` does not implement recurring billing.
- VS-002D activation and grant creation are atomic.


## v0.2.8 VS-000 coding-ready rules

- PV-041: `VS-000` SHALL be the only slice marked `READY_FOR_CODING`.
- PV-042: `VS-000` SHALL require fake Paystack adapter fixtures for automated tests.
- PV-043: `VS-000` SHALL allow optional manual Paystack sandbox smoke tests but SHALL NOT require live Paystack in CI.
- PV-044: `VS-000` SHALL require one monthly fixed-term plan and `expires_at` calculation.
- PV-045: `VS-000` SHALL explicitly forbid UI, real recurring billing, Paystack subscription creation, and discount calculation.
