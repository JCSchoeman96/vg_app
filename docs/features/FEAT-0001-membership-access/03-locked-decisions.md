# 03 — Locked Decisions

## D-001: VS-000C boundary

VS-000C SHALL implement Memberships/access foundation only.

VS-000C SHALL NOT implement Catalog, Commerce, Paystack, UI, discounts, refunds, cancellations, or recurring billing.

## D-002: EntitlementGrant included now

`EntitlementGrant` SHALL be included in VS-000C because real access evaluation needs real grants.

## D-003: System-only activation

VS-000C SHALL allow actual active memberships through controlled system-only activation.

## D-004: No expiry mutation action in VS-000C

`expire_due_memberships` SHALL NOT be implemented in VS-000C. Access evaluation SHALL defensively deny expired memberships/grants.

## D-005: Commerce references nullable

`Membership.activation_order_id` and `EntitlementGrant.source_order_id` SHALL be nullable until Commerce exists.

TODO VS-000E/Commerce: make these required where paid fulfilment owns activation/grant creation.

## D-006: Duration support

VS-000C SHALL model and test:

- monthly fixed-period
- yearly fixed-period
- lifetime

## D-007: Auto-renewing modelled but blocked

`auto_renewing` MAY exist as a plan value, but SHALL be blocked from live/public activation until recurring capability exists.

## D-008: Plan/benefit activation order

A `BenefitRule` MAY activate while its `MembershipPlan` is draft or active, but not archived.

A `MembershipPlan` MAY activate only when:

- its MembershipProduct is active
- at least one active BenefitRule exists

## D-009: Access evaluation key

Access evaluation SHALL use:

```text
user_id + benefit_type + benefit_scope
```

## D-010: Access validity

Access is granted only when:

- membership state is `active`
- grant state is `active`
- `starts_at <= now`
- `now < expires_at` when expiry exists
- `valid_from_at <= now`
- `now < valid_until_at` when validity end exists

## D-011: Lifetime validity

Lifetime memberships and grants SHALL use `expires_at = nil` and `valid_until_at = nil`.

## D-012: Calendar duration

Monthly/yearly expiry SHALL use calendar interval/count logic.

One month after January 31 SHALL clamp to February 28/29 at the same time where possible.

## D-013: Idempotency

Membership activation called twice SHALL return/reuse the existing active membership and SHALL NOT duplicate grants.

Grant creation called twice SHALL return/reuse existing grants and SHALL NOT duplicate records.

## D-014: Active membership uniqueness

One active membership per user per membership product SHALL be enforced with a database partial unique index where feasible.

## D-015: Multiple pending memberships

Multiple pending memberships for the same user/product SHALL be allowed.

## D-016: AccountRole read policy

AccountRole broad read policy SHOULD be hardened in VS-000C0 or VS-000C1 before more role-dependent functionality grows.
