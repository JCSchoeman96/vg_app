# 02 — Backend Grill-me Results

## Resources

VS-000C SHALL introduce these resources in `VgApp.Memberships`:

- `VgApp.Memberships.MembershipProduct`
- `VgApp.Memberships.MembershipPlan`
- `VgApp.Memberships.BenefitRule`
- `VgApp.Memberships.Membership`
- `VgApp.Memberships.EntitlementGrant`

## Actions

See `05-action-cards.md` for detailed action cards.

Minimum domain actions:

- `Memberships.create_membership_product`
- `Memberships.activate_membership_product`
- `Memberships.create_membership_plan`
- `Memberships.activate_membership_plan`
- `Memberships.create_benefit_rule`
- `Memberships.activate_benefit_rule`
- `Memberships.create_pending_membership`
- `Memberships.activate_membership`
- `Memberships.create_entitlement_grants`
- `Memberships.evaluate_entitlement_access`

## Policies

- Product/plan/benefit setup: `:system` or `staff_admin`
- Membership activation: `:system` only in VS-000C
- Membership/grant reads: owner user, `staff_admin`, or `:system`
- Public writes: forbidden in VS-000C

## States

See `01-feature-grill-me.md`.

## Invariants

- One active membership per user per membership product.
- Multiple pending memberships are allowed.
- Auto-renewing plans cannot be live until recurring capability exists.
- Active plan requires active product and at least one active benefit rule.
- BenefitRule can activate for draft or active non-archived plan.
- Grant validity cannot exceed membership validity.
- Access evaluation is read-only and defensive.

## DB constraints

- UUIDv7 primary keys.
- UTC microsecond timestamps.
- Unique membership product code.
- Unique plan code per membership product.
- Unique benefit rule code per product/plan scope.
- Partial unique index for active membership per user/product where feasible.
- Unique active grant per membership/benefit rule where feasible.

## Tests

VS-000C SHALL be split into micro-slice tests. See `07-slice-plan.md`.

## CI gates

Before PR ready:

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
```

## Forbidden scope

See `10-forbidden-scope.md`.
