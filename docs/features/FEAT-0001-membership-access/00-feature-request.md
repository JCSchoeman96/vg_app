# 00 — Feature Request

## Feature

Membership access foundation for `vg_app`.

## Business need

The platform needs a controlled way to define membership products and plans, create paid/activated memberships later through Commerce, and evaluate whether a user has access to specific member benefits.

## First intended membership product

`Vriendinneklub`

## Required capabilities

The system SHALL eventually support:

- monthly fixed-term memberships
- yearly fixed-term memberships
- lifetime memberships
- future auto-renewing subscription plans
- entitlement-based access
- payment-review access blocking

## VS-000C scope

VS-000C SHALL implement Memberships/access foundation only.

VS-000C SHALL NOT implement:

- Catalog offers/prices
- Commerce orders/payments
- Paystack
- real fulfilment pipeline
- public UI
- admin UI
- discount calculation
- refunds
- cancellations
- recurring billing
