# VS-002C — Paystack First-Payment Evidence and Fulfilment Authority

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `Order`
- `Payment`
- `PaymentMethod`
- `PaymentEvent`
- `Membership`
- `EntitlementGrant`

## Actions involved
- `Commerce.initialize_paystack_transaction`
- `Commerce.submit_order_for_payment`
- `Commerce.ingest_paystack_webhook`
- `Commerce.record_payment_event`
- `Commerce.verify_paystack_transaction`
- `Commerce.mark_payment_succeeded`
- `Commerce.mark_order_paid`
- `Commerce.record_payment_method`
- `Commerce.fulfil_paid_order`
- `Commerce.move_payment_to_review`

## Blocking decisions
- none

## Required tests
- `paystack_callback_does_not_activate_membership_without_verify_success`
- `callback_verify_success_can_provisionally_fulfil_order`
- `webhook_success_confirms_provisional_fulfilment`
- `verify_pending_does_not_fulfil`
- `invalid_paystack_signature_rejected`
- `duplicate_payment_event_does_not_create_second_row`
- `duplicate_fulfilment_does_not_duplicate_membership_or_grants`
- `contradictory_event_moves_payment_membership_and_grants_to_review`
- `raw_paystack_payload_is_restricted_and_hashed`

## Slice law
Callback presence SHALL NOT deliver value.

Callback Verify success MAY provisionally fulfil only through `Commerce.fulfil_paid_order`.
Webhook `charge.success` SHALL remain authoritative and SHALL confirm fulfilment through the same `Commerce.fulfil_paid_order` action.

Contradictory Paystack status after provisional fulfilment SHALL move Payment, Membership, and EntitlementGrant into `payment_review`; `payment_review` access SHALL be denied pending reconciliation.

VS-002C SHALL NOT create Paystack subscriptions.
VS-002C SHALL NOT implement renewal invoices, dunning, or failed renewal recovery.
