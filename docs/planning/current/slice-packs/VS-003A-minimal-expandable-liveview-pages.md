# VS-003A — Minimal Expandable LiveView Pages

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `User`
- `Order`
- `Payment`
- `Membership`
- `EntitlementGrant`

## Actions involved
- `Accounts.register_user`
- `Accounts.confirm_email`
- `Accounts.login_user`
- `Commerce.create_pending_order`
- `Commerce.initialize_paystack_transaction`
- `Commerce.submit_order_for_payment`
- `Memberships.evaluate_entitlement_access`

## Blocking decisions
- none

## Required tests
- `minimal_pages_do_not_create_business_truth`
- `paystack_callback_shows_pending_only`

## Slice law
Minimal pages may be implemented after the backend tracer is semantically correct:

- register
- confirm email
- login
- join membership product
- payment pending/verifying
- thank-you / membership active

Pages SHALL call domain actions and SHALL NOT own business truth.
