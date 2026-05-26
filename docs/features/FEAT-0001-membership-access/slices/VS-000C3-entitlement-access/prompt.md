# Coding Prompt — VS-000C3

Implement VS-000C3 only.

## Goal

Add `EntitlementGrant`, idempotent grant creation, and defensive access evaluation.

## Allowed

- EntitlementGrant resource/actions/policies/migrations/snapshots/tests.
- `Memberships.create_entitlement_grants`
- `Memberships.evaluate_entitlement_access`
- nullable `source_order_id` with TODO for VS-000E/Commerce
- access evaluation by `user_id + benefit_type + benefit_scope`
- payment_review blocking
- expired membership/grant blocking
- read-only access evaluation

## Forbidden

- Catalog
- Commerce
- Paystack
- UI
- discount calculation
- schedulers
- cancellation/refund/subscription logic

## Required success test

```text
product
|> plan
|> benefit
|> pending membership
|> activate membership
|> create grants
|> evaluate access true
```

## Required negative tests

- pending membership denies access
- expired membership denies access
- payment_review membership denies access
- payment_review grant denies access
- archived product/plan cannot activate or produce access
- duplicate active membership blocked
- duplicate grants not created
- access evaluation does not mutate state

## Required checks

```bash
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

Open PR:

```text
VS-000C3: Entitlement grants and access evaluation
```
