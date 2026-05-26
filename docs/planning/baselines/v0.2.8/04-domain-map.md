# 04. Domain Map

## Accounts
Owns authenticated users, profiles, consent records, and staff role assignment.

## Memberships
Owns membership products, membership plans, benefit rules, memberships, entitlement grants, expiry, and access evaluation.

## Catalog
Owns membership-only offers and prices. Catalog SHALL NOT become a generic product catalog in v0.2.7.

## Commerce
Owns orders, order items, payments, Paystack event evidence, payment methods, and the single idempotent fulfilment pipeline.

## Deferred Commerce
`Subscription` is a deferred resource card only. Paystack subscription lifecycle is not active in v0.2.7.

## Platform Laws
- All primary IDs SHALL use UUIDv7.
- All persisted timestamps SHALL use UTC microsecond precision.
- UUIDv7 ordering SHALL NOT be business truth.
