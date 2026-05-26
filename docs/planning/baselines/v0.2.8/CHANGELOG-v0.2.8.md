# CHANGELOG — v0.2.8

## Purpose
Create the first coding-ready patch from v0.2.7 by authorizing only `VS-000 — Backend Membership Commerce Tracer`.

## Added
- VS-000 implementation mode contract.
- Fake Paystack adapter requirement for automated tests.
- Optional manual Paystack sandbox smoke allowance.
- Explicit one-month fixed-term tracer membership rule.
- Explicit VS-000 forbidden scope list.
- Validator checks PV-041 through PV-045 for VS-000 coding readiness.

## Changed
- `planning-pack.yml` version moved to `0.2.8`.
- `coding_status` changed to `VS_000_READY_FOR_CODING_ONLY`.
- `VS-000` readiness changed to `READY_FOR_CODING`.
- All other slices changed to `NOT_READY`.

## Preserved
- UUIDv7 primary key law.
- UTC microsecond timestamp law.
- Paystack callback/Verify/webhook authority law.
- PaymentMethod active resource.
- Subscription resource deferred.
- Auto-renewing plans not sellable until recurring capability exists.

## Still deferred
- Real recurring billing.
- Paystack subscription creation.
- Full Paystack production integration required by CI.
- Admin UI.
- Public LiveView pages.
- Discount calculation.
- Refunds.
- Events, learning, CMS, and community implementation.
