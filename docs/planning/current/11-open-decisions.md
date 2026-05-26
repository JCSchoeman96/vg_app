# 11. Open Decisions

## v0.2.7 Locked Decisions

- UUIDv7 SHALL be used for platform primary keys.
- UTC microsecond precision SHALL be used for persisted timestamps.
- UUIDv7 ordering SHALL be secondary technical ordering only, never authoritative business event ordering.
- Paystack is the first payment gateway target.
- Paystack Verify success MAY provisionally fulfil an order only through `Commerce.fulfil_paid_order`.
- Paystack webhook processing SHALL remain authoritative over provisional callback/Verify fulfilment.
- Contradictory Paystack statuses SHALL move Payment, Membership, and EntitlementGrant to `payment_review`; access is blocked pending reconciliation.
- `PaymentMethod` is active in v0.2.7 for safe Paystack authorization metadata.
- `Subscription` is a deferred card only in v0.2.7.
- `renewal_mode = auto_renewing` may be modelled, but it is not live/sellable until recurring capability exists.

## Deferred Beyond v0.2.7

- Automatic recurring billing.
- Paystack subscription creation.
- Renewal invoices.
- Failed renewal recovery.
- Dunning.
- Upgrade/downgrade and proration.
- Cancellation self-service.
- Refunds.
- Discount calculation.
- Full admin UI.

## Still Requires Future Grill

- Exact v0.3 Paystack subscription lifecycle resource/action law.
- Cancellation, retry, and renewal failure semantics.
- Public-facing subscription wording and legal copy before launch.
