# VS-002A — Configure Membership Product, Plans, Benefits, Offer, and Prices

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `MembershipProduct`
- `MembershipPlan`
- `BenefitRule`
- `Offer`
- `Price`

## Actions involved
- `Memberships.create_membership_product`
- `Memberships.activate_membership_product`
- `Memberships.create_membership_plan`
- `Memberships.create_benefit_rule`
- `Memberships.activate_benefit_rule`
- `Memberships.activate_membership_plan`
- `Catalog.create_membership_offer`
- `Catalog.create_membership_price`
- `Catalog.activate_membership_price`
- `Catalog.activate_membership_offer`

## Blocking decisions
- none

## Required tests
- `creates_membership_product_with_unique_code`
- `creates_monthly_yearly_and_lifetime_plans`
- `rejects_invalid_duration_configuration`
- `benefit_rule_can_activate_for_draft_or_active_plan`
- `rejects_second_active_price`
- `recurring_ready_does_not_create_subscription`

## Slice law
Vriendinneklub SHALL be configured as the first MembershipProduct.

Monthly, yearly, and lifetime plans SHALL be possible. `recurring_ready` price metadata SHALL NOT create a Paystack subscription or renewal workflow in v0.2.7.
