# VS-000 — Backend Membership Commerce Tracer

## Status
READY_FOR_CODING

## Purpose
VS-000 is the first coding-authorized backend tracer bullet. It SHALL prove the commercial membership spine using production-shaped Ash resources, actions, migrations, policies, and tests.

It SHALL NOT become the full product build. It authorizes only the foundation needed to prove the backend path.

## Implementation mode

```yaml
implementation_mode:
  real_backend_foundation: true
  production_shaped_ash_resources: true
  production_shaped_actions: true
  production_shaped_migrations: true
  real_liveview_pages: false
  real_admin_ui: false
  real_paystack_network_required_in_ci: false
  fake_paystack_adapter_required_for_automated_tests: true
  manual_paystack_sandbox_smoke_allowed: true
  subscription_engine: false
```

## Resources involved
- `User`
- `UserProfile`
- `ConsentRecord`
- `AccountRole`
- `MembershipProduct`
- `MembershipPlan`
- `Membership`
- `BenefitRule`
- `EntitlementGrant`
- `Offer`
- `Price`
- `Order`
- `OrderItem`
- `Payment`
- `PaymentMethod`
- `PaymentEvent`

## Actions involved
- `Accounts.register_user`
- `Accounts.confirm_email`
- `Accounts.bootstrap_staff_admin`
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
- `Commerce.create_pending_order`
- `Commerce.add_membership_order_item`
- `Commerce.initialize_paystack_transaction`
- `Commerce.submit_order_for_payment`
- `Commerce.ingest_paystack_webhook`
- `Commerce.record_payment_event`
- `Commerce.mark_payment_succeeded`
- `Commerce.mark_order_paid`
- `Commerce.move_payment_to_review`
- `Commerce.fulfil_paid_order`
- `Commerce.record_payment_method`
- `Commerce.verify_paystack_transaction`
- `Memberships.create_pending_membership`
- `Memberships.activate_membership`
- `Memberships.create_entitlement_grants`
- `Memberships.evaluate_entitlement_access`

## Blocking decisions
- none

## Required tracer flow

```text
confirmed user
|> terms/privacy consent records exist
|> minimal AccountRole foundation exists
|> configured Vriendinneklub MembershipProduct
|> one monthly fixed-term MembershipPlan
|> active BenefitRule set
|> active Offer and Price
|> pending Order and OrderItem
|> fake Paystack Verify success OR fake Paystack webhook charge.success
|> PaymentEvent recorded idempotently
|> Commerce.fulfil_paid_order called as the single fulfilment pipeline
|> PaymentMethod stores safe authorization metadata only
|> Order paid/fulfilled
|> Membership active with expires_at calculated
|> EntitlementGrant active with validity window
|> Memberships.evaluate_entitlement_access returns true
```

## Paystack boundary law
- VS-000 SHALL define a Paystack provider adapter boundary.
- Automated tests SHALL use fake Paystack adapter fixtures.
- Automated CI SHALL NOT require live Paystack connectivity.
- Manual sandbox smoke tests MAY use Paystack test keys, but they SHALL NOT be required for CI green.
- Callback presence SHALL NOT deliver value.
- Callback Verify success MAY provisionally fulfil only through `Commerce.fulfil_paid_order`.
- Webhook `charge.success` SHALL use the same `Commerce.fulfil_paid_order` action.
- Duplicate Verify or webhook success SHALL be idempotent and SHALL NOT duplicate memberships, grants, payments, or payment methods.

## Authentication and role law
- VS-000 SHALL include minimal AshAuthentication resource setup sufficient to support production-shaped `User` identity fields.
- VS-000 SHALL NOT implement full registration UI, login UI, password-reset UI, or public auth pages.
- VS-000 SHALL support confirmed test/user fixtures through domain actions or controlled test setup.
- VS-000 SHALL include `ConsentRecord` for `terms` and `privacy_policy`.
- VS-000 MAY omit marketing consent from the tracer path.
- VS-000 SHALL include `AccountRole` foundation and staff-admin authorization for setup actions.
- `system` SHALL NOT be stored as a user role.

## Membership setup law
- VS-000 SHALL create membership product, plan, benefit rule, offer, and price through normal Ash/domain actions.
- VS-000 SHALL NOT bypass domain actions with raw DB inserts for business setup.
- VS-000 SHALL use one monthly fixed-term plan.
- VS-000 SHALL calculate `expires_at` for the monthly fixed-term membership.
- VS-000 SHALL NOT implement monthly/yearly/lifetime plan matrix; that belongs to VS-002A.

## Payment-review law
- VS-000 SHALL prove that `payment_review` blocks access.
- VS-000 SHALL NOT implement the full Paystack contradiction matrix; that belongs to VS-002C.

## Required tests
- `backend_tracer_proves_full_membership_commerce_spine`
- `fixed_period_membership_sets_expires_at`
- `callback_verify_success_can_provisionally_fulfil_order`
- `webhook_success_confirms_provisional_fulfilment`
- `duplicate_fulfilment_does_not_duplicate_membership_or_grants`
- `duplicate_success_event_does_not_duplicate_success_effects`
- `payment_review_grant_blocks_access`
- `payment_review_membership_blocks_access`
- `stores_paystack_authorization_metadata_without_raw_card_data`
- `auto_renewing_plan_cannot_go_live_without_recurring_capability`
- `access_evaluation_does_not_mutate_state`

## Forbidden in VS-000
- Real recurring billing
- Paystack subscription creation
- Paystack subscription lifecycle handling
- Full Paystack production integration required by CI
- Admin UI
- Public LiveView pages
- Discount calculation
- Refunds
- Event ticketing
- CMS/content engine
- Learning/LMS
- Community implementation
- Cancellation self-service
- Upgrade/downgrade
- Dunning or failed renewal recovery

## Completion rule
VS-000 is complete only when the tracer test and smaller invariant tests pass without weakening tests, bypassing domain actions, or implementing forbidden scope.
