# 05. Resource Cards

## Resource Card Standard

Every resource card is authoritative only after the relevant slice is marked READY_FOR_CODING.


---

## Resource: User

```yaml
resource: User
domain: Accounts
purpose: Represents a real authenticated account using AshAuthentication email/password
  auth.
owns:
- account identity
- email confirmation state
- authentication-linked user record
- account lifecycle state
does_not_own:
- profile details
- consent history
- role assignment history
- membership lifecycle
- order totals
- payment state
- entitlement grants
state:
- pending_confirmation
- active
- suspended
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Accounts
ash_resource_module: VGApp.Accounts.User
relationships:
- has_one user_profile
- has_many consent_records
- has_many account_roles
- has_many memberships
- has_many orders
identities:
- unique_email
high_risk_invariants:
- email must be unique and normalized
- password hashing SHALL be handled by AshAuthentication
- unconfirmed users SHALL NOT create membership orders
- suspended users SHALL NOT start protected v0.2.8 flows
actions_active_v0_2:
- Accounts.register_user
- Accounts.confirm_email
- Accounts.login_user
- Accounts.request_password_reset
- Accounts.reset_password
actions_deferred:
- Accounts.change_email
- Accounts.delete_account
tests_required:
- registers_user_with_required_profile_and_consents
- rejects_duplicate_email
- unconfirmed_user_cannot_create_order
- confirmed_user_can_create_order
- login_requires_valid_credentials
- password_reset_token_can_reset_password
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
  notes: Primary key.
- name: email
  type: ci_string
  required: true
  nullable: false
  unique_identity: unique_email
  notes: Normalized email used for AshAuthentication identity.
- name: hashed_password
  type: string
  required: true
  nullable: false
  generated: AshAuthentication
  notes: No plain password SHALL be stored.
- name: confirmed_at
  type: utc_datetime_usec
  required: false
  nullable: true
  notes: Null until email confirmation succeeds.
- name: state
  type: enum
  required: true
  nullable: false
  default: pending_confirmation
  allowed_values:
  - pending_confirmation
  - active
  - suspended
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: UserProfile

```yaml
resource: UserProfile
domain: Accounts
purpose: Stores registration profile fields that are not authentication credentials.
owns:
- first name
- last name
- optional phone number
does_not_own:
- passwords
- roles
- membership state
- consent history
state:
- active
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Accounts
ash_resource_module: VGApp.Accounts.UserProfile
relationships:
- belongs_to user
identities:
- unique_user_profile_per_user
high_risk_invariants:
- one profile per user
- phone number is optional in v0.2.8 unless a later business rule requires it
actions_active_v0_2:
- Accounts.register_user
actions_deferred:
- Accounts.update_profile
tests_required:
- registers_user_with_required_profile_and_consents
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
  notes: FK to User.
- name: first_name
  type: string
  required: true
  nullable: false
- name: last_name
  type: string
  required: true
  nullable: false
- name: phone_number
  type: string
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: ConsentRecord

```yaml
resource: ConsentRecord
domain: Accounts
purpose: Records legal/marketing consent decisions separately from user identity.
owns:
- terms acceptance
- privacy policy acceptance
- marketing consent history
does_not_own:
- user auth
- membership access
- email subscription provider state
state:
- accepted
- revoked
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Accounts
ash_resource_module: VGApp.Accounts.ConsentRecord
relationships:
- belongs_to user
identities:
- unique_active_consent_type_version_per_user
high_risk_invariants:
- terms and privacy_policy consent SHALL be required before registration completes
- marketing consent SHALL be optional and separate
- marketing consent SHALL NOT be bundled into terms or privacy acceptance
actions_active_v0_2:
- Accounts.register_user
actions_deferred:
- Accounts.revoke_marketing_consent
tests_required:
- terms_and_privacy_consent_required
- marketing_consent_optional_and_separate
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: consent_type
  type: enum
  required: true
  nullable: false
  allowed_values:
  - terms
  - privacy_policy
  - marketing
- name: consent_version
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: accepted
  allowed_values:
  - accepted
  - revoked
- name: accepted_at
  type: utc_datetime_usec
  required: true
  nullable: false
- name: revoked_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: source
  type: enum
  required: true
  nullable: false
  allowed_values:
  - registration_form
  - account_settings
  - admin_import
- name: ip_address_hash
  type: string
  required: false
  nullable: true
- name: user_agent_hash
  type: string
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: AccountRole

```yaml
resource: AccountRole
domain: Accounts
purpose: Assigns real authenticated users to application roles such as staff_admin.
owns:
- role assignments
- role lifecycle
does_not_own:
- system actor identity
- domain permissions themselves
- business resource ownership
state:
- active
- revoked
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Accounts
ash_resource_module: VGApp.Accounts.AccountRole
relationships:
- belongs_to user
- belongs_to granted_by_user optional
identities:
- unique_active_role_per_user
high_risk_invariants:
- system SHALL NOT be stored as a normal user role
- staff_admin is a real authenticated role
- initial staff_admin bootstrap SHALL be system/seed controlled
actions_active_v0_2:
- Accounts.bootstrap_staff_admin
- Accounts.assign_role
actions_deferred:
- Accounts.revoke_role
tests_required:
- system_is_not_stored_as_user_role
- staff_admin_role_required_for_admin_actions
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: role
  type: enum
  required: true
  nullable: false
  allowed_values:
  - customer
  - staff_admin
- name: state
  type: enum
  required: true
  nullable: false
  default: active
  allowed_values:
  - active
  - revoked
- name: granted_by_user_id
  type: uuid_v7
  required: false
  nullable: true
- name: granted_at
  type: utc_datetime_usec
  required: true
  nullable: false
- name: revoked_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: MembershipProduct

```yaml
resource: MembershipProduct
domain: Memberships
purpose: Defines a membership product/family such as Vriendinneklub without creating
  a generic catalog.
owns:
- membership product code
- membership product lifecycle
does_not_own:
- physical products
- event tickets
- courses
- inventory
- generic catalog variants
state:
- draft
- active
- archived
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Memberships
ash_resource_module: VGApp.Memberships.MembershipProduct
relationships:
- has_many membership_plans
- has_many memberships
- has_many benefit_rules
identities:
- unique_membership_product_code
high_risk_invariants:
- MembershipProduct is not a generic product catalog
- Vriendinneklub SHALL be the first configured membership product
- archived products cannot be purchased
actions_active_v0_2:
- Memberships.create_membership_product
- Memberships.activate_membership_product
actions_deferred:
- Memberships.archive_membership_product
tests_required:
- creates_membership_product_with_unique_code
- rejects_duplicate_membership_product_code
- archived_membership_product_cannot_be_purchased
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: code
  type: string
  required: true
  nullable: false
  unique_identity: unique_membership_product_code
- name: name
  type: string
  required: true
  nullable: false
- name: description
  type: string
  required: false
  nullable: true
- name: state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - active
  - archived
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: MembershipPlan

```yaml
resource: MembershipPlan
domain: Memberships
purpose: Defines purchasable membership terms under a membership product, including fixed-term and future auto-renewing subscription intent.
owns:
- membership duration configuration
- renewal mode declaration
- plan lifecycle and sale gate
does_not_own:
- price amount
- order totals
- payment provider state
- Paystack subscription lifecycle
state:
- draft
- active
- archived
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Memberships
ash_resource_module: VGApp.Memberships.MembershipPlan
relationships:
- belongs_to membership_product
- has_many prices
- has_many memberships
- has_many benefit_rules
identities:
- unique_plan_code_per_membership_product
high_risk_invariants:
- fixed_period plans SHALL have duration_interval and duration_interval_count
- lifetime plans SHALL have duration_interval = none and duration_interval_count = null
- renewal_mode fixed_term SHALL be sellable in v0.2.8
- renewal_mode auto_renewing SHALL be modelled in v0.2.8 but SHALL NOT be live/sellable until Paystack recurring capability is enabled
- subscription wording MAY be prepared internally, but public sale of auto-renewing plans SHALL wait for recurring billing implementation
- active plan requires an active MembershipProduct and at least one active BenefitRule
- archived plans cannot be purchased
actions_active_v0_2:
- Memberships.create_membership_plan
- Memberships.activate_membership_plan
actions_deferred:
- Memberships.archive_membership_plan
- Memberships.enable_auto_renewing_plan
- Commerce.create_paystack_subscription
tests_required:
- creates_monthly_yearly_and_lifetime_plans
- rejects_invalid_duration_configuration
- duplicate_plan_code_rejected
- archived_plan_cannot_be_purchased
- auto_renewing_plan_cannot_go_live_without_recurring_capability
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: code
  type: string
  required: true
  nullable: false
- name: name
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - active
  - archived
- name: duration_type
  type: enum
  required: true
  nullable: false
  allowed_values:
  - fixed_period
  - lifetime
- name: duration_interval
  type: enum
  required: true
  nullable: false
  allowed_values:
  - month
  - year
  - none
- name: duration_interval_count
  type: integer
  required: false
  nullable: true
- name: renewal_mode
  type: enum
  required: true
  nullable: false
  default: fixed_term
  allowed_values:
  - fixed_term
  - auto_renewing
  notes: auto_renewing is not live/sellable in v0.2.8 unless recurring capability is explicitly enabled.
- name: public_sale_state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - internal_test
  - live
- name: requires_recurring_capability
  type: boolean
  required: true
  nullable: false
  default: false
- name: starts_membership_immediately
  type: boolean
  required: true
  nullable: false
  default: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Membership

```yaml
resource: Membership
domain: Memberships
purpose: Represents a user membership purchased under a specific membership product and plan.
owns:
- membership lifecycle
- membership validity window
- purchased duration snapshot
- payment-review membership hold state
does_not_own:
- payment state
- grant definitions
- provider subscriptions
- discount calculation
state:
- pending_payment
- active
- expired
- cancelled
- payment_review
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Memberships
ash_resource_module: VGApp.Memberships.Membership
relationships:
- belongs_to user
- belongs_to membership_product
- belongs_to membership_plan
- belongs_to activation_order
- has_many entitlement_grants
identities:
- one_active_membership_per_user_per_membership_product
high_risk_invariants:
- A user SHALL NOT have more than one active membership per membership_product_id
- pending membership SHALL NOT grant access
- payment_review membership SHALL deny access until reconciled
- duration terms SHALL be snapshotted at activation time
- lifetime membership SHALL have expires_at = null
- fixed_period membership SHALL calculate expires_at from activated_at using UTC microsecond precision
- UUIDv7 ordering SHALL NOT be authoritative business event ordering
actions_active_v0_2:
- Memberships.create_pending_membership
- Memberships.activate_membership
- Memberships.evaluate_entitlement_access
- Memberships.expire_due_memberships
actions_deferred:
- Memberships.cancel_membership
- Memberships.reconcile_payment_review_membership
tests_required:
- creates_pending_membership_without_access
- membership_snapshots_duration_terms
- lifetime_membership_has_no_expiry
- fixed_period_membership_sets_expires_at
- blocks_second_active_membership_per_product
- payment_review_membership_blocks_access
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  nullable: false
- name: activation_order_id
  type: uuid_v7
  required: false
  nullable: true
- name: state
  type: enum
  required: true
  nullable: false
  default: pending_payment
  allowed_values:
  - pending_payment
  - active
  - expired
  - cancelled
  - payment_review
- name: duration_type_snapshot
  type: enum
  required: false
  nullable: true
  allowed_values:
  - fixed_period
  - lifetime
- name: duration_interval_snapshot
  type: enum
  required: false
  nullable: true
  allowed_values:
  - month
  - year
  - none
- name: duration_interval_count_snapshot
  type: integer
  required: false
  nullable: true
- name: starts_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: expires_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: activated_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: cancelled_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: expired_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_reason
  type: string
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: BenefitRule

```yaml
resource: BenefitRule
domain: Memberships
purpose: Defines benefits that an active membership product/plan grants.
owns:
- benefit definitions
- benefit type/scope
- grant generation rules
does_not_own:
- member access evaluation result
- payment state
- discount calculation
state:
- draft
- active
- archived
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Memberships
ash_resource_module: VGApp.Memberships.BenefitRule
relationships:
- belongs_to membership_product
- belongs_to membership_plan optional
- has_many entitlement_grants
identities:
- unique_rule_code_per_membership_product_or_plan
high_risk_invariants:
- benefit_type is required
- BenefitRule may activate for a draft or active non-archived MembershipPlan
- active BenefitRule SHALL NOT require an already-active MembershipPlan
- archived BenefitRules SHALL NOT create grants
- discount-access BenefitRule SHALL not calculate discounts in v0.2.8
actions_active_v0_2:
- Memberships.create_benefit_rule
- Memberships.activate_benefit_rule
actions_deferred:
- Memberships.archive_benefit_rule
tests_required:
- reject_duplicate_rule_code_per_product_or_plan
- benefit_rule_can_activate_for_draft_or_active_plan
- archived_benefit_rule_does_not_create_grants
- discount_benefit_does_not_calculate_discount
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: false
  nullable: true
- name: code
  type: string
  required: true
  nullable: false
- name: name
  type: string
  required: true
  nullable: false
- name: benefit_type
  type: enum
  required: true
  nullable: false
  allowed_values:
  - member_content_access
  - member_community_access
  - member_status
  - vriendinneklub_discount_access
- name: benefit_scope
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - active
  - archived
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: EntitlementGrant

```yaml
resource: EntitlementGrant
domain: Memberships
purpose: Records actual access grants created from active BenefitRules for a paid active Membership.
owns:
- grant lifecycle
- grant validity window
- grant source references
- payment-review access block state
does_not_own:
- benefit definitions
- payment state
- content records
- discount calculation
state:
- active
- expired
- revoked
- payment_review
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Memberships
ash_resource_module: VGApp.Memberships.EntitlementGrant
relationships:
- belongs_to user
- belongs_to membership
- belongs_to membership_product
- belongs_to benefit_rule
- belongs_to source_order
identities:
- unique_active_grant_per_membership_benefit_rule
high_risk_invariants:
- grant validity SHALL not exceed membership validity
- valid_until_at = null only for lifetime memberships
- access evaluation SHALL check grant date validity defensively
- payment_review grants SHALL deny access
- EntitlementGrant SHALL not calculate discounts
actions_active_v0_2:
- Memberships.create_entitlement_grants
- Memberships.evaluate_entitlement_access
actions_deferred:
- Memberships.revoke_entitlement_grant
- Memberships.reconcile_payment_review_grant
tests_required:
- benefit_rule_creates_expected_grants
- grant_validity_matches_membership_validity
- expired_grant_blocks_access
- access_evaluation_does_not_mutate_state
- payment_review_grant_blocks_access
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: benefit_rule_id
  type: uuid_v7
  required: true
  nullable: false
- name: source_order_id
  type: uuid_v7
  required: true
  nullable: false
- name: benefit_type
  type: enum
  required: true
  nullable: false
  allowed_values:
  - member_content_access
  - member_community_access
  - member_status
  - vriendinneklub_discount_access
- name: benefit_scope
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: active
  allowed_values:
  - active
  - expired
  - revoked
  - payment_review
- name: valid_from_at
  type: utc_datetime_usec
  required: true
  nullable: false
- name: valid_until_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: revoked_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_reason
  type: string
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Offer

```yaml
resource: Offer
domain: Catalog
purpose: Defines a purchasable membership offer without creating a generic catalog.
owns:
- offer code
- offer lifecycle
- membership plan offered
does_not_own:
- price amount
- order state
- generic product catalog
- events/courses/products
state:
- draft
- active
- archived
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Catalog
ash_resource_module: VGApp.Catalog.Offer
relationships:
- belongs_to membership_product
- belongs_to membership_plan
- has_many prices
identities:
- unique_offer_code
high_risk_invariants:
- active offer requires active membership product, active membership plan, and active
  price
- Offer SHALL remain membership-only in v0.2.8
actions_active_v0_2:
- Catalog.create_membership_offer
- Catalog.activate_membership_offer
actions_deferred:
- Catalog.archive_offer
tests_required:
- rejects_duplicate_offer_code
- offer_requires_active_plan_and_price
- offer_remains_membership_only
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  nullable: false
- name: code
  type: string
  required: true
  nullable: false
  unique_identity: unique_offer_code
- name: name
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - active
  - archived
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Price

```yaml
resource: Price
domain: Catalog
purpose: Defines active membership price terms before purchase.
owns:
- currency
- amount
- billing mode
- billing interval metadata
does_not_own:
- order item snapshot
- payment provider subscription
- renewal invoices
state:
- draft
- active
- archived
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Catalog
ash_resource_module: VGApp.Catalog.Price
relationships:
- belongs_to offer
- belongs_to membership_plan
identities:
- one_active_price_per_offer
high_risk_invariants:
- active price amount/currency SHALL be immutable for existing order item snapshots
- recurring_ready SHALL NOT mean automatic recurring billing is implemented in v0.2.8
- recurring_ready MAY only store metadata needed for future auto-renewing support
- fixed-period membership plan duration SHALL match selected price billing interval in v0.2.8
actions_active_v0_2:
- Catalog.create_membership_price
- Catalog.activate_membership_price
- Catalog.snapshot_price_for_order_item
actions_deferred:
- Catalog.archive_price
tests_required:
- rejects_second_active_price
- snapshot_contains_amount_currency_price_and_duration_source
- snapshot_does_not_mutate_price
- recurring_ready_does_not_create_subscription
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: offer_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  nullable: false
- name: currency
  type: string
  required: true
  nullable: false
  default: ZAR
- name: amount_minor
  type: integer
  required: true
  nullable: false
- name: billing_mode
  type: enum
  required: true
  nullable: false
  allowed_values:
  - one_time
  - recurring_ready
- name: billing_interval
  type: enum
  required: true
  nullable: false
  allowed_values:
  - month
  - year
  - none
- name: billing_interval_count
  type: integer
  required: false
  nullable: true
- name: state
  type: enum
  required: true
  nullable: false
  default: draft
  allowed_values:
  - draft
  - active
  - archived
- name: effective_from_at
  type: utc_datetime_usec
  required: true
  nullable: false
- name: effective_until_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Order

```yaml
resource: Order
domain: Commerce
purpose: Represents a membership purchase order for one membership product/plan in v0.2.8.
owns:
- order lifecycle
- order totals
- customer order reference
- fulfilment authority pointer
does_not_own:
- price truth after snapshot
- payment provider event truth
- direct membership activation without fulfilment pipeline
- grant creation without fulfilment pipeline
state:
- pending_payment
- payment_processing
- paid
- fulfilled
- cancelled
- payment_review
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.Order
relationships:
- belongs_to user
- has_many order_items
- has_one payment
- has_one membership
identities:
- unique_order_ref
high_risk_invariants:
- orders SHALL require confirmed authenticated users
- order totals SHALL equal sum of order item snapshots
- one pending order per user per membership_product may be reused until paid/cancelled
- Commerce.fulfil_paid_order SHALL be the only action that may coordinate payment success, order paid, membership activation, and grant creation
- fulfilment SHALL be idempotent across Paystack webhook and Paystack Verify sources
actions_active_v0_2:
- Commerce.create_pending_order
- Commerce.add_membership_order_item
- Commerce.submit_order_for_payment
- Commerce.mark_order_paid
- Commerce.fulfil_paid_order
actions_deferred:
- Commerce.cancel_order
- Commerce.refund_order
tests_required:
- confirmed_user_can_create_order
- unconfirmed_user_cannot_create_order
- amount_mismatch_blocks_order_paid
- mark_order_paid_does_not_activate_membership
- mark_order_paid_does_not_create_grants
- callback_verify_success_can_provisionally_fulfil_order
- webhook_success_confirms_provisional_fulfilment
- duplicate_fulfilment_does_not_duplicate_membership_or_grants
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: order_ref
  type: string
  required: true
  nullable: false
  unique_identity: unique_order_ref
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  default: pending_payment
  allowed_values:
  - pending_payment
  - payment_processing
  - paid
  - fulfilled
  - cancelled
  - payment_review
- name: currency
  type: string
  required: true
  nullable: false
  default: ZAR
- name: total_amount_minor
  type: integer
  required: true
  nullable: false
- name: submitted_for_payment_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: paid_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: fulfilled_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: cancelled_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: OrderItem

```yaml
resource: OrderItem
domain: Commerce
purpose: Snapshots purchased membership offer/price/duration terms at order time.
owns:
- price snapshot
- duration snapshot
- membership product/plan snapshot
does_not_own:
- live price
- payment state
- membership activation
state:
- active
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.OrderItem
relationships:
- belongs_to order
- belongs_to offer
- belongs_to price
- belongs_to membership_product
- belongs_to membership_plan
identities:
- one_membership_item_per_order
high_risk_invariants:
- OrderItem SHALL snapshot amount, currency, price_id, offer_id, membership_product_id,
  membership_plan_id, and duration terms
- OrderItem snapshots SHALL NOT mutate when live Price or Plan changes
- v0.2.8 order SHALL contain one membership item only
actions_active_v0_2:
- Commerce.add_membership_order_item
- Catalog.snapshot_price_for_order_item
actions_deferred:
- Commerce.remove_order_item
tests_required:
- snapshot_contains_amount_currency_price_and_duration_source
- snapshot_does_not_mutate_price
- rejects_duplicate_membership_item_for_order
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: order_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_product_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  nullable: false
- name: offer_id
  type: uuid_v7
  required: true
  nullable: false
- name: price_id
  type: uuid_v7
  required: true
  nullable: false
- name: description
  type: string
  required: true
  nullable: false
- name: quantity
  type: integer
  required: true
  nullable: false
  default: 1
- name: currency
  type: string
  required: true
  nullable: false
- name: unit_amount_minor
  type: integer
  required: true
  nullable: false
- name: total_amount_minor
  type: integer
  required: true
  nullable: false
- name: duration_type_snapshot
  type: enum
  required: true
  nullable: false
  allowed_values:
  - fixed_period
  - lifetime
- name: duration_interval_snapshot
  type: enum
  required: true
  nullable: false
  allowed_values:
  - month
  - year
  - none
- name: duration_interval_count_snapshot
  type: integer
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Payment

```yaml
resource: Payment
domain: Commerce
purpose: Tracks a Paystack payment attempt for an order, including provisional Verify fulfilment and webhook authority state.
owns:
- payment lifecycle
- provider references
- server-side transaction verification result
- fulfilment authority state
does_not_own:
- raw provider event idempotency
- membership activation outside fulfilment pipeline
- grant creation outside fulfilment pipeline
- provider subscription lifecycle
state:
- initialized
- processing
- succeeded
- cancelled
- payment_review
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.Payment
relationships:
- belongs_to order
- has_many payment_events
- has_many payment_methods
identities:
- unique_provider_transaction_reference
high_risk_invariants:
- Paystack callback/return URL SHALL NOT deliver value unless server-side Paystack Verify returns success and then only through Commerce.fulfil_paid_order
- webhook processing SHALL remain authoritative over provisional Verify fulfilment
- contradictory Paystack status after provisional fulfilment SHALL move Payment, Membership, and EntitlementGrant into payment_review
- Payment SHALL NOT activate membership or create grants directly
actions_active_v0_2:
- Commerce.initialize_paystack_transaction
- Commerce.submit_order_for_payment
- Commerce.verify_paystack_transaction
- Commerce.mark_payment_succeeded
- Commerce.move_payment_to_review
actions_deferred:
- Commerce.mark_payment_failed
- Commerce.create_paystack_subscription
tests_required:
- paystack_callback_does_not_activate_membership_without_verify_success
- callback_verify_success_can_provisionally_fulfil_order
- webhook_success_confirms_provisional_fulfilment
- contradictory_event_moves_payment_membership_and_grants_to_review
- recurring_ready_does_not_create_subscription
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: order_id
  type: uuid_v7
  required: true
  nullable: false
- name: provider
  type: enum
  required: true
  nullable: false
  default: paystack
  allowed_values:
  - paystack
- name: state
  type: enum
  required: true
  nullable: false
  default: initialized
  allowed_values:
  - initialized
  - processing
  - succeeded
  - cancelled
  - payment_review
- name: fulfilment_authority_state
  type: enum
  required: true
  nullable: false
  default: none
  allowed_values:
  - none
  - provisional_verify_success
  - webhook_confirmed
  - payment_review
- name: amount_minor
  type: integer
  required: true
  nullable: false
- name: currency
  type: string
  required: true
  nullable: false
  default: ZAR
- name: provider_customer_code
  type: string
  required: false
  nullable: true
- name: provider_transaction_reference
  type: string
  required: false
  nullable: true
- name: provider_subscription_code
  type: string
  required: false
  nullable: true
- name: initialized_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: succeeded_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: webhook_confirmed_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: payment_review_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```



---

## Resource: PaymentMethod

```yaml
resource: PaymentMethod
domain: Commerce
purpose: Stores reusable, non-sensitive Paystack authorization metadata captured from a verified successful payment for future recurring billing.
owns:
- provider authorization metadata
- safe card display metadata
- reusable-payment-method lifecycle
does_not_own:
- raw card data
- recurring subscription lifecycle
- customer identity outside provider references
state:
- active
- disabled
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.PaymentMethod
relationships:
- belongs_to user
- belongs_to first_seen_payment
identities:
- unique_provider_authorization_per_user
high_risk_invariants:
- raw card data SHALL never be stored
- provider_authorization_code MAY be stored only as Paystack authorization metadata for future recurring charges
- PaymentMethod SHALL NOT create Paystack subscriptions in v0.2.8
- UUIDv7 ordering SHALL NOT be authoritative business event ordering
actions_active_v0_2:
- Commerce.record_payment_method
actions_deferred:
- Commerce.disable_payment_method
- Commerce.charge_payment_method_for_renewal
tests_required:
- stores_paystack_authorization_metadata_without_raw_card_data
- payment_method_does_not_create_subscription
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: provider
  type: enum
  required: true
  nullable: false
  default: paystack
  allowed_values:
  - paystack
- name: provider_customer_code
  type: string
  required: false
  nullable: true
- name: provider_authorization_code
  type: string
  required: true
  nullable: false
- name: card_type
  type: string
  required: false
  nullable: true
- name: last4
  type: string
  required: false
  nullable: true
- name: exp_month
  type: integer
  required: false
  nullable: true
- name: exp_year
  type: integer
  required: false
  nullable: true
- name: reusable
  type: boolean
  required: true
  nullable: false
  default: false
- name: state
  type: enum
  required: true
  nullable: false
  default: active
  allowed_values:
  - active
  - disabled
- name: first_seen_payment_id
  type: uuid_v7
  required: true
  nullable: false
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```

---

## Resource: PaymentEvent

```yaml
resource: PaymentEvent
domain: Commerce
purpose: Stores idempotent Paystack webhook and Verify API evidence that drives payment state transitions and reconciliation.
owns:
- provider event idempotency
- restricted raw payload evidence
- raw payload hash
- signature verification evidence
- processing state
- provider status/event normalization
does_not_own:
- membership activation outside Commerce.fulfil_paid_order
- grant creation outside Commerce.fulfil_paid_order
- provider subscription lifecycle implementation
state:
- received
- processed
- ignored_or_unhandled
- errored
source_of_truth: postgres
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.PaymentEvent
relationships:
- belongs_to payment optional
- belongs_to order optional
identities:
- unique_provider_event_identity
high_risk_invariants:
- Webhook and Verify processing SHALL be idempotent
- duplicate Paystack events SHALL NOT create duplicate payments, orders, memberships, or grants
- signature_valid must be true for Paystack webhook success processing
- provider_event_identity SHALL be deterministic even when provider event_id is unavailable
- raw_payload_encrypted SHALL be access-restricted; raw_payload_hash SHALL support reconciliation without exposing payload
- Paystack Verify success and webhook charge.success SHALL call the same idempotent fulfilment action
actions_active_v0_2:
- Commerce.ingest_paystack_webhook
- Commerce.record_payment_event
- Commerce.verify_paystack_transaction
actions_deferred:
- Commerce.handle_paystack_subscription_event
- Commerce.handle_failed_renewal_event
tests_required:
- duplicate_payment_event_does_not_create_second_row
- duplicate_success_event_does_not_duplicate_success_effects
- invalid_paystack_signature_rejected
- paystack_charge_success_event_marks_order_paid_only_once
- raw_paystack_payload_is_restricted_and_hashed
open_decisions: []
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: database_or_ash
- name: provider
  type: enum
  required: true
  nullable: false
  default: paystack
  allowed_values:
  - paystack
- name: event_source
  type: enum
  required: true
  nullable: false
  allowed_values:
  - paystack_webhook
  - paystack_verify_api
  - internal_system
- name: provider_event_id
  type: string
  required: false
  nullable: true
- name: provider_event_identity
  type: string
  required: true
  nullable: false
  notes: Deterministic unique identity derived from provider + event id or provider + event_type + transaction reference + raw_payload_hash.
- name: provider_event_type
  type: string
  required: false
  nullable: true
- name: event_type
  type: string
  required: true
  nullable: false
- name: provider_status
  type: string
  required: false
  nullable: true
- name: provider_transaction_reference
  type: string
  required: false
  nullable: true
- name: provider_subscription_code
  type: string
  required: false
  nullable: true
- name: raw_payload_encrypted
  type: binary_or_encrypted_map
  required: true
  nullable: false
- name: raw_payload_hash
  type: string
  required: true
  nullable: false
- name: signature_valid
  type: boolean
  required: true
  nullable: false
  default: false
- name: received_at
  type: utc_datetime_usec
  required: true
  nullable: false
- name: occurred_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: processed_at
  type: utc_datetime_usec
  required: false
  nullable: true
- name: processing_state
  type: enum
  required: true
  nullable: false
  default: received
  allowed_values:
  - received
  - processed
  - ignored_or_unhandled
  - errored
- name: processing_error_code
  type: string
  required: false
  nullable: true
- name: payment_id
  type: uuid_v7
  required: false
  nullable: true
- name: order_id
  type: uuid_v7
  required: false
  nullable: true
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: database
```


---

## Resource: Subscription

```yaml
resource: Subscription
domain: Commerce
active_in_v0_2_7: false
purpose: Deferred resource card for future Paystack auto-renewing subscription lifecycle; it documents shape but SHALL NOT be implemented in v0.2.8.
owns:
- future provider subscription lifecycle
- future recurring billing state
- future renewal invoice linkage
does_not_own:
- first-payment transaction success
- fixed-term membership fulfilment
state:
- deferred
source_of_truth: postgres_future
tenant_scope: global
ash_domain_module: VGApp.Commerce
ash_resource_module: VGApp.Commerce.Subscription
relationships:
- belongs_to user future
- belongs_to membership future
- belongs_to payment_method future
identities:
- unique_provider_subscription_code future
high_risk_invariants:
- Subscription SHALL remain a deferred card only in v0.2.8
- Auto-renewing plans SHALL NOT be live/sellable until this lifecycle is implemented
- Paystack subscription.create and invoice events SHALL be handled in a future slice, not in v0.2.8
actions_active_v0_2: []
actions_deferred:
- Commerce.create_paystack_subscription
- Commerce.handle_paystack_subscription_event
- Commerce.handle_failed_renewal_event
- Commerce.cancel_subscription
tests_required:
- subscription_resource_is_deferred_not_active
- auto_renewing_plan_cannot_go_live_without_recurring_capability
open_decisions:
- v0.3_recurring_subscription_lifecycle
field_schema:
- name: id
  type: uuid_v7
  required: true
  nullable: false
  generated: future_database_or_ash
- name: user_id
  type: uuid_v7
  required: true
  nullable: false
- name: membership_id
  type: uuid_v7
  required: true
  nullable: false
- name: payment_method_id
  type: uuid_v7
  required: true
  nullable: false
- name: provider
  type: enum
  required: true
  nullable: false
  allowed_values:
  - paystack
- name: provider_subscription_code
  type: string
  required: true
  nullable: false
- name: state
  type: enum
  required: true
  nullable: false
  allowed_values:
  - deferred
- name: inserted_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: future_database
- name: updated_at
  type: utc_datetime_usec
  required: true
  nullable: false
  generated: future_database
```
