# 01 — Feature Grill-me Results

## What must exist?

- MembershipProduct
- MembershipPlan
- BenefitRule
- Membership
- EntitlementGrant
- `Memberships.evaluate_entitlement_access`

## Who uses it?

In VS-000C:

- `:system` actor for controlled setup and activation.
- `staff_admin` for product/plan/benefit setup.
- owner user for reading own memberships/grants once policies exist.

Public user purchase is deferred to Catalog/Commerce slices.

## What states exist?

### MembershipProduct

- `draft`
- `active`
- `archived`

### MembershipPlan

- `draft`
- `active`
- `archived`

### BenefitRule

- `draft`
- `active`
- `archived`

### Membership

- `pending_payment`
- `active`
- `expired`
- `cancelled`
- `payment_review`

`cancelled` exists as a state, but cancellation action is deferred.

### EntitlementGrant

- `active`
- `expired`
- `revoked`
- `payment_review`

## Edge cases

- January 31 + one calendar month clamps to February 28/29.
- Lifetime memberships have no expiry.
- Active membership without valid grant denies access.
- Active grant with expired/payment-review membership denies access.
- Duplicate activation must not duplicate grants.
- Duplicate grant creation must be idempotent.
- Multiple pending memberships for the same user/product are allowed.
- Only one active membership per user/product is allowed.

## What must never happen?

- Pending memberships must never grant access.
- Payment-review memberships/grants must never grant access.
- UUIDv7 ordering must never be treated as authoritative business event ordering.
- Auto-renewing plans must never go live until recurring capability is implemented.
- Discount benefit eligibility must never calculate price discounts in VS-000C.
- Commerce, Catalog, Paystack, and UI must not leak into VS-000C.

## v1 vs later

### VS-000C / now

- Define membership products/plans/benefits.
- Define membership lifecycle.
- Define entitlement grants.
- Define access evaluation.
- Use nullable Commerce reference fields until Commerce lands.

### Later

- Catalog Offer/Price
- Commerce Order/Payment
- Paystack verification/webhooks
- real paid fulfilment
- recurring billing
- admin UI
- public UI
- discounts
- cancellations
- refunds

## Hidden assumptions exposed

- `source_order_id` cannot be required until Commerce exists.
- `activation_order_id` cannot be required until Commerce exists.
- Access must be benefit-based, not vague product-based.
- Plan activation has a setup-order problem: active benefit rules may need to exist before plan activation.
- Tests must cover monthly/yearly/lifetime now to avoid weak duration design.
