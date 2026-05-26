# 00. Project Seed Brief — v0.2.7

VG App is an Ash 3.x / Phoenix / Elixir project. v0.2.7 defines the minimal membership commerce foundation using Vriendinneklub as the first configured membership product.

v0.2.7 hardens Paystack first-payment semantics, recurring-readiness gates, PaymentMethod capture, and payment-review reversal handling. It does not implement automatic recurring billing.

## Platform Laws

- Primary keys SHALL be UUIDv7.
- Persisted timestamps SHALL use UTC microsecond precision.
- UUIDv7 ordering is a secondary technical aid only; business event order SHALL use explicit timestamps, provider metadata, or domain sequence.

## Scope Boundary

v0.2.7 supports first-payment fulfilment for membership terms and prepares the data model for future subscriptions. Paystack subscription lifecycle remains deferred.
