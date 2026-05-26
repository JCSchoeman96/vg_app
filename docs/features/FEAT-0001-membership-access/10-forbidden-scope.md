# 10 — Forbidden Scope

VS-000C SHALL NOT implement:

- Catalog Offer
- Catalog Price
- Commerce Order
- Commerce OrderItem
- Commerce Payment
- Commerce PaymentEvent
- PaymentMethod
- Paystack adapter
- Paystack verify/callback/webhook logic
- real fulfilment pipeline
- public LiveView pages
- admin UI
- discount calculation
- coupon logic
- refunds
- cancellation self-service
- recurring billing
- Paystack subscription lifecycle
- dunning
- failed renewal recovery
- CMS/content engine
- LMS/learning
- community features

Coding agents SHALL stop and report `BLOCKED` if any assigned prompt requires these in VS-000C.
