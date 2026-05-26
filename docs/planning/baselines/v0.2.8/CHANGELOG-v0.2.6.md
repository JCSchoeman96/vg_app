# CHANGELOG v0.2.7

## Changed

- Reframed scope from hardcoded Join Vriendinneklub to minimal membership commerce foundation with Vriendinneklub as first `MembershipProduct`.
- Added real AshAuthentication planning boundary.
- Added `UserProfile`, `ConsentRecord`, and `AccountRole` resources.
- Added `MembershipProduct` resource.
- Hardened monthly/yearly/lifetime duration modelling.
- Added membership duration snapshots and expiry fields.
- Added entitlement grant validity windows.
- Introduced Paystack as first gateway target.
- Hardened Paystack callback rule: callback never delivers value.
- Hardened `PaymentEvent` idempotency and signature evidence.
- Explicitly deferred recurring billing, renewal invoices, dunning, upgrades/downgrades, proration, self-service cancellation, Paystack subscription lifecycle, and discount calculation.
- Added VS-000 backend tracer bullet.
- Added VS-003A minimal expandable LiveView page slice.
- Extended executable validator to PV-001 through PV-030.

## Still not coding-ready

No slice is READY_FOR_CODING. The next step is the next `/grill-me` round, focused on Paystack and subscription-product semantics.
