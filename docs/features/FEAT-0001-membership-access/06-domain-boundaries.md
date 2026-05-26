# 06 — Domain Boundaries

## Memberships owns

- membership products
- membership plans
- benefit rules
- memberships
- entitlement grants
- entitlement access evaluation

## Memberships does not own

- catalog offers
- prices
- orders
- payments
- Paystack
- discount calculation
- content records
- community records
- UI
- admin surfaces

## Boundary rules

### Catalog boundary

Catalog will later turn an active MembershipPlan into an Offer/Price combination.

VS-000C SHALL NOT create Offer or Price.

### Commerce boundary

Commerce will later own Order, OrderItem, Payment, PaymentEvent, and paid fulfilment.

VS-000C SHALL keep Commerce references nullable and SHALL NOT create Order.

### Payment boundary

Paystack callback/verify/webhook flows belong to Commerce/payment slices.

VS-000C SHALL NOT touch Paystack.

### Access boundary

Memberships owns entitlement access evaluation as a defensive read/action.

Access evaluation SHALL NOT rely on schedulers to be correct.
