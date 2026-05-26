# Voelgoed Ash Agent Pack v0.2.8

This planning pack is the first **coding-ready slice patch** for the VG App membership commerce foundation.

## Status

```yaml
version: 0.2.8
coding_status: VS_000_READY_FOR_CODING_ONLY
validator_status: PASSED
```

Only `VS-000 — Backend Membership Commerce Tracer` is authorized for implementation.

Every other slice remains `NOT_READY` and SHALL NOT be implemented until it passes its own slice-specific `/grill-me` and patch.

## What changed in v0.2.8

- Marked `VS-000` as `READY_FOR_CODING`.
- Marked all other slices as `NOT_READY`.
- Locked VS-000 as a real backend foundation tracer, not a test-only toy.
- Required real Ash resources/actions/migrations for the tracer path.
- Required fake Paystack adapter fixtures for automated tests.
- Allowed optional manual Paystack sandbox smoke tests with test keys.
- Forbid live Paystack connectivity as a CI requirement.
- Locked one monthly fixed-term membership plan for VS-000.
- Required `expires_at` calculation in the tracer.
- Required both Verify-success and webhook-success paths to use `Commerce.fulfil_paid_order`.
- Required `payment_review` access blocking, but deferred the full contradiction matrix.
- Preserved recurring/subscription engine deferral.

## Development use

Give a coding agent only the current pack plus the `VS-000` slice pack. The agent SHALL implement only VS-000 and SHALL stop if it needs details outside the authorized slice.
