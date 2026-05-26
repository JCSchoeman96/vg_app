# CHANGELOG v0.2.7

## Added

- Platform-wide UUIDv7 primary key law.
- Platform-wide UTC microsecond timestamp law.
- UUIDv7 secondary-ordering-only rule.
- Active `PaymentMethod` resource.
- Deferred-only `Subscription` resource card.
- `renewal_mode`, `public_sale_state`, and `requires_recurring_capability` on `MembershipPlan`.
- `payment_review` states on `Order`, `Payment`, `Membership`, and `EntitlementGrant`.
- `Commerce.verify_paystack_transaction`.
- `Commerce.record_payment_method`.
- `Commerce.fulfil_paid_order`.
- `Commerce.move_payment_to_review`.
- VS-002F recurring-readiness/payment-method slice.
- Validator checks PV-031 through PV-040.

## Changed

- Paystack callback Verify success may provisionally fulfil only through the same idempotent fulfilment action used by webhook success.
- Paystack webhook remains authoritative.
- Contradictory provider state moves the commercial chain to `payment_review` instead of silent cancellation.

## Deferred

- Paystack subscription creation.
- Automatic recurring billing.
- Renewal invoices, failed renewal recovery, dunning, cancellation lifecycle, upgrade/downgrade, proration, and discount calculation.
