# 04 — Resource Cards

## MembershipProduct

```yaml
resource: MembershipProduct
domain: Memberships
module: VgApp.Memberships.MembershipProduct
purpose: Defines a membership product/family such as Vriendinneklub without creating a generic catalog.
state: [draft, active, archived]
tenant_scope: global
source_of_truth: postgres
relationships:
  - has_many membership_plans
  - has_many memberships
  - has_many benefit_rules
identities:
  - unique_membership_product_code
fields:
  id: uuid_v7 primary key
  code: string required unique
  name: string required
  description: string nullable
  state: enum required default draft
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
invariants:
  - MembershipProduct is not a generic product catalog.
  - Archived products cannot be activated/purchased.
```

## MembershipPlan

```yaml
resource: MembershipPlan
domain: Memberships
module: VgApp.Memberships.MembershipPlan
purpose: Defines membership terms under a MembershipProduct.
state: [draft, active, archived]
relationships:
  - belongs_to membership_product
  - has_many memberships
  - has_many benefit_rules
identities:
  - unique_plan_code_per_membership_product
fields:
  id: uuid_v7 primary key
  membership_product_id: uuid_v7 required
  code: string required
  name: string required
  state: enum required default draft
  duration_type: enum [fixed_period, lifetime] required
  duration_interval: enum [month, year, none] required
  duration_interval_count: integer nullable
  renewal_mode: enum [fixed_term, auto_renewing] required default fixed_term
  public_sale_state: enum [draft, internal_test, live] required default draft
  requires_recurring_capability: boolean required default false
  starts_membership_immediately: boolean required default true
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
invariants:
  - fixed_period plans require duration interval/count.
  - lifetime plans require duration_interval none and count nil.
  - auto_renewing cannot be live until recurring capability exists.
  - active plan requires active product and at least one active benefit rule.
```

## BenefitRule

```yaml
resource: BenefitRule
domain: Memberships
module: VgApp.Memberships.BenefitRule
purpose: Defines benefits granted by a membership product/plan.
state: [draft, active, archived]
relationships:
  - belongs_to membership_product
  - belongs_to membership_plan optional
  - has_many entitlement_grants
identities:
  - unique_rule_code_per_membership_product_or_plan
fields:
  id: uuid_v7 primary key
  membership_product_id: uuid_v7 required
  membership_plan_id: uuid_v7 nullable
  code: string required
  name: string required
  benefit_type: enum required
  benefit_scope: string required
  state: enum required default draft
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
benefit_type_values:
  - member_content_access
  - member_community_access
  - member_status
  - vriendinneklub_discount_access
invariants:
  - Discount benefit grants eligibility only; no discount calculation in VS-000C.
  - Archived BenefitRules shall not create grants.
```

## Membership

```yaml
resource: Membership
domain: Memberships
module: VgApp.Memberships.Membership
purpose: Represents a user's membership under a product/plan.
state: [pending_payment, active, expired, cancelled, payment_review]
relationships:
  - belongs_to user
  - belongs_to membership_product
  - belongs_to membership_plan
  - has_many entitlement_grants
fields:
  id: uuid_v7 primary key
  user_id: uuid_v7 required
  membership_product_id: uuid_v7 required
  membership_plan_id: uuid_v7 required
  activation_order_id: uuid_v7 nullable
  state: enum required default pending_payment
  duration_type_snapshot: enum nullable
  duration_interval_snapshot: enum nullable
  duration_interval_count_snapshot: integer nullable
  starts_at: utc_datetime_usec nullable
  expires_at: utc_datetime_usec nullable
  activated_at: utc_datetime_usec nullable
  cancelled_at: utc_datetime_usec nullable
  expired_at: utc_datetime_usec nullable
  payment_review_at: utc_datetime_usec nullable
  payment_review_reason: string nullable
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
invariants:
  - One active membership per user/product.
  - Pending/payment_review/cancelled/expired memberships deny access.
  - Duration terms are snapshotted at activation.
```

## EntitlementGrant

```yaml
resource: EntitlementGrant
domain: Memberships
module: VgApp.Memberships.EntitlementGrant
purpose: Records actual access grants created from active BenefitRules for an active Membership.
state: [active, expired, revoked, payment_review]
relationships:
  - belongs_to user
  - belongs_to membership
  - belongs_to membership_product
  - belongs_to benefit_rule
fields:
  id: uuid_v7 primary key
  user_id: uuid_v7 required
  membership_id: uuid_v7 required
  membership_product_id: uuid_v7 required
  benefit_rule_id: uuid_v7 required
  source_order_id: uuid_v7 nullable
  benefit_type: enum required
  benefit_scope: string required
  state: enum required default active
  valid_from_at: utc_datetime_usec required
  valid_until_at: utc_datetime_usec nullable
  revoked_at: utc_datetime_usec nullable
  payment_review_at: utc_datetime_usec nullable
  payment_review_reason: string nullable
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
invariants:
  - Grant validity cannot exceed membership validity.
  - payment_review grants deny access.
  - Access evaluation must be defensive and read-only.
  - source_order_id is nullable until VS-000E/Commerce.
```
