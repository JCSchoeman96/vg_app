# 05 — Action Cards

## Memberships.create_membership_product

```yaml
action: create_membership_product
resource: MembershipProduct
actor: system_or_staff_admin
inputs: [code, name, description]
result: draft MembershipProduct
tests:
  - creates_membership_product_with_unique_code
  - rejects_duplicate_membership_product_code
```

## Memberships.activate_membership_product

```yaml
action: activate_membership_product
resource: MembershipProduct
actor: system_or_staff_admin
inputs: [id]
preconditions:
  - product state is draft
result: active MembershipProduct
tests:
  - activates_draft_product
  - archived_product_cannot_activate
```

## Memberships.create_membership_plan

```yaml
action: create_membership_plan
resource: MembershipPlan
actor: system_or_staff_admin
inputs:
  - membership_product_id
  - code
  - name
  - duration_type
  - duration_interval
  - duration_interval_count
  - renewal_mode
  - public_sale_state
  - requires_recurring_capability
result: draft MembershipPlan
tests:
  - creates_monthly_yearly_and_lifetime_plans
  - rejects_invalid_duration_configuration
  - duplicate_plan_code_rejected
```

## Memberships.activate_membership_plan

```yaml
action: activate_membership_plan
resource: MembershipPlan
actor: system_or_staff_admin
preconditions:
  - membership product is active
  - plan is not archived
  - at least one active BenefitRule exists for plan/product
  - auto_renewing is not live unless recurring capability exists
result: active MembershipPlan
tests:
  - active_plan_requires_active_product
  - active_plan_requires_active_benefit_rule
  - auto_renewing_plan_cannot_go_live_without_recurring_capability
```

## Memberships.create_benefit_rule

```yaml
action: create_benefit_rule
resource: BenefitRule
actor: system_or_staff_admin
inputs:
  - membership_product_id
  - membership_plan_id optional
  - code
  - name
  - benefit_type
  - benefit_scope
result: draft BenefitRule
tests:
  - creates_benefit_rule
  - rejects_duplicate_rule_code_per_product_or_plan
```

## Memberships.activate_benefit_rule

```yaml
action: activate_benefit_rule
resource: BenefitRule
actor: system_or_staff_admin
preconditions:
  - product is not archived
  - plan is draft or active, not archived
result: active BenefitRule
tests:
  - benefit_rule_can_activate_for_draft_or_active_plan
  - archived_plan_blocks_benefit_rule_activation
  - discount_benefit_does_not_calculate_discount
```

## Memberships.create_pending_membership

```yaml
action: create_pending_membership
resource: Membership
actor: system
inputs:
  - user_id
  - membership_product_id
  - membership_plan_id
result: pending_payment Membership
tests:
  - creates_pending_membership_without_access
  - allows_multiple_pending_memberships
```

## Memberships.activate_membership

```yaml
action: activate_membership
resource: Membership
actor: system
inputs:
  - membership_id
  - now
  - activation_order_id optional
result: active Membership
effects:
  - snapshots duration terms from MembershipPlan
  - sets starts_at, activated_at, expires_at
  - idempotently returns existing active membership if already active
tests:
  - fixed_period_membership_sets_expires_at
  - yearly_membership_sets_expires_at
  - lifetime_membership_has_no_expiry
  - jan_31_monthly_expiry_clamps_to_feb_28_or_29
  - blocks_second_active_membership_per_product
  - second_activation_does_not_duplicate_membership_or_grants
```

## Memberships.create_entitlement_grants

```yaml
action: create_entitlement_grants
resource: EntitlementGrant
actor: system
inputs:
  - membership_id
  - now
  - source_order_id optional
result: list of EntitlementGrant records
preconditions:
  - membership is active
  - active BenefitRules exist
effects:
  - creates grants idempotently
  - copies benefit_type and benefit_scope
  - sets validity based on membership validity
tests:
  - benefit_rule_creates_expected_grants
  - grant_validity_matches_membership_validity
  - duplicate_grant_creation_is_idempotent
```

## Memberships.evaluate_entitlement_access

```yaml
action: evaluate_entitlement_access
kind: read/domain function
actor: system_or_user_or_staff_admin
inputs:
  - user_id
  - benefit_type
  - benefit_scope
  - now
returns:
  - allowed boolean
  - reason atom/string
rules:
  - only active memberships count
  - only active grants count
  - membership and grant validity windows must both contain now
  - payment_review membership/grant denies access
  - evaluation must not mutate state
tests:
  - active_membership_and_grant_allows_access
  - pending_membership_denies_access
  - expired_membership_denies_access
  - payment_review_membership_denies_access
  - payment_review_grant_denies_access
  - expired_grant_denies_access
  - access_evaluation_does_not_mutate_state
```
