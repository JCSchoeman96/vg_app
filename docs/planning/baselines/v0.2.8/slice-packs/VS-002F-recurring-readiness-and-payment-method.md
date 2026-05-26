# VS-002F — Recurring Readiness and PaymentMethod Capture

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `MembershipPlan`
- `Payment`
- `PaymentMethod`

## Actions involved
- `Commerce.record_payment_method`

## Blocking decisions
- none

## Required tests
- `stores_paystack_authorization_metadata_without_raw_card_data`
- `payment_method_does_not_create_subscription`
- `auto_renewing_plan_cannot_go_live_without_recurring_capability`
- `subscription_resource_is_deferred_not_active`

## Slice law
v0.2.7 may store safe Paystack authorization metadata for future recurring billing.

v0.2.7 SHALL NOT create Paystack subscriptions.

`renewal_mode = auto_renewing` is modelled but SHALL NOT be live/sellable until recurring capability is implemented.
