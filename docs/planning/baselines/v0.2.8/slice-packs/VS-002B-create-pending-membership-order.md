# VS-002B — Create Pending Membership Order

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `User`
- `MembershipProduct`
- `MembershipPlan`
- `Offer`
- `Price`
- `Order`
- `OrderItem`
- `Membership`

## Actions involved
- `Commerce.create_pending_order`
- `Catalog.snapshot_price_for_order_item`
- `Commerce.add_membership_order_item`
- `Memberships.create_pending_membership`

## Blocking decisions
- none

## Required tests
- `confirmed_user_can_create_order`
- `unconfirmed_user_cannot_create_order`
- `blocks_second_active_membership_per_product`
- `snapshot_contains_amount_currency_price_and_duration_source`
- `creates_pending_membership_without_access`

## Slice law
Only confirmed authenticated users may create a membership order.

This slice creates/reuses a pending order, snapshots price and duration terms, and creates a pending Membership. A pending Membership SHALL NOT grant access.
