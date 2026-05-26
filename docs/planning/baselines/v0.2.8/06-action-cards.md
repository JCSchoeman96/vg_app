# 06. Action Cards

## Action Card Standard

Every action card SHALL define actor, arguments, returns, mutations, forbidden behaviours, and tests.


---

## Action: Accounts.register_user

```yaml
action: Accounts.register_user
resource: User
domain: Accounts
actor: public_visitor
trigger: []
preconditions:
- email_is_unique
- password_confirmation_matches
- terms_and_privacy_consent_present
state_changes:
- 'User: null -> pending_confirmation'
- 'UserProfile: null -> active'
- 'ConsentRecord: null -> accepted'
side_effects:
- enqueue_email_confirmation_after_commit
transaction_boundary: creates User, UserProfile, and required ConsentRecords atomically;
  confirmation email side effect after commit
idempotency: duplicate email returns deterministic duplicate_email
authorization: public_visitor allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_membership_implicitly
- creating_order_implicitly
- storing_plain_password
- bundling_marketing_consent_with_terms
tests_required:
- registers_user_with_required_profile_and_consents
- rejects_duplicate_email
- terms_and_privacy_consent_required
- marketing_consent_optional_and_separate
- does_not_create_membership
open_decisions: []
primary_resource: User
mutates_resources:
- User
- UserProfile
- ConsentRecord
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: email
  type: ci_string
  required: true
  source: argument
  nullable: false
- name: password
  type: string
  required: true
  source: argument
  nullable: false
- name: password_confirmation
  type: string
  required: true
  source: argument
  nullable: false
- name: first_name
  type: string
  required: true
  source: argument
  nullable: false
- name: last_name
  type: string
  required: true
  source: argument
  nullable: false
- name: phone_number
  type: string
  required: false
  source: argument
  nullable: false
- name: terms_consent_version
  type: string
  required: true
  source: argument
  nullable: false
- name: privacy_policy_consent_version
  type: string
  required: true
  source: argument
  nullable: false
- name: marketing_consent
  type: boolean
  required: false
  source: argument
  nullable: false
returns:
  resource: User
  shape: record_with_profile_and_required_consents
errors:
- duplicate_email
- invalid_email
- password_confirmation_mismatch
- terms_consent_required
- privacy_consent_required
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.confirm_email

```yaml
action: Accounts.confirm_email
resource: User
domain: Accounts
actor: public_confirmation_link
trigger: []
preconditions:
- confirmation_token_valid
state_changes:
- 'User.confirmed_at: null -> now'
- 'User.state: pending_confirmation -> active'
side_effects: []
transaction_boundary: updates User confirmation state in one transaction
idempotency: not_required
authorization: public_confirmation_link allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_membership_implicitly
tests_required:
- confirmed_user_can_create_order
- invalid_confirmation_token_rejected
open_decisions: []
primary_resource: User
mutates_resources:
- User
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: confirmation_token
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: User
  shape: record
errors:
- invalid_or_expired_confirmation_token
- already_confirmed
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.login_user

```yaml
action: Accounts.login_user
resource: User
domain: Accounts
actor: public_visitor
trigger: []
preconditions:
- valid_credentials
- user_confirmed
- user_not_suspended
state_changes: []
side_effects: []
transaction_boundary: read/authentication action only
idempotency: not_required
authorization: public_visitor allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_user_implicitly
- creating_order_implicitly
tests_required:
- login_requires_valid_credentials
open_decisions: []
primary_resource: User
mutates_resources: []
action_type: read
ash_action_kind: read
visibility: public
accepted_arguments:
- name: email
  type: ci_string
  required: true
  source: argument
  nullable: false
- name: password
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: Session
  shape: auth_session
errors:
- invalid_credentials
- user_not_confirmed
- user_suspended
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.request_password_reset

```yaml
action: Accounts.request_password_reset
resource: User
domain: Accounts
actor: public_visitor
trigger: []
preconditions: []
state_changes: []
side_effects:
- enqueue_password_reset_email_after_commit
transaction_boundary: generic acknowledgement; token persistence handled by AshAuthentication
idempotency: not_required
authorization: public_visitor allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- revealing_whether_email_exists
tests_required:
- password_reset_request_does_not_reveal_account_existence
open_decisions: []
primary_resource: User
mutates_resources: []
action_type: generic
ash_action_kind: action
visibility: public
accepted_arguments:
- name: email
  type: ci_string
  required: true
  source: argument
  nullable: false
returns:
  resource: PasswordResetRequest
  shape: generic_ack
errors:
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.reset_password

```yaml
action: Accounts.reset_password
resource: User
domain: Accounts
actor: public_visitor
trigger: []
preconditions:
- reset_token_valid
- password_confirmation_matches
state_changes: []
side_effects: []
transaction_boundary: updates credential through AshAuthentication
idempotency: not_required
authorization: public_visitor allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- logging_plain_password
tests_required:
- password_reset_token_can_reset_password
open_decisions: []
primary_resource: User
mutates_resources:
- User
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: reset_token
  type: string
  required: true
  source: argument
  nullable: false
- name: password
  type: string
  required: true
  source: argument
  nullable: false
- name: password_confirmation
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: User
  shape: record
errors:
- invalid_or_expired_reset_token
- password_confirmation_mismatch
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.bootstrap_staff_admin

```yaml
action: Accounts.bootstrap_staff_admin
resource: AccountRole
domain: Accounts
actor: system
trigger: []
preconditions:
- system_bootstrap_context_only
state_changes: []
side_effects: []
transaction_boundary: creates initial staff_admin role in controlled bootstrap transaction
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_system_user_role
tests_required:
- system_is_not_stored_as_user_role
- staff_admin_role_required_for_admin_actions
open_decisions: []
primary_resource: AccountRole
mutates_resources:
- AccountRole
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: user_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: AccountRole
  shape: record
errors:
- user_not_found
- role_already_exists
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Accounts.assign_role

```yaml
action: Accounts.assign_role
resource: AccountRole
domain: Accounts
actor: staff_admin
trigger: []
preconditions:
- actor_has_staff_admin_role
- role_is_customer_or_staff_admin
state_changes: []
side_effects: []
transaction_boundary: creates role assignment in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- assigning_system_as_login_role
tests_required:
- staff_admin_role_required_for_admin_actions
open_decisions: []
primary_resource: AccountRole
mutates_resources:
- AccountRole
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: user_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: role
  type: enum
  required: true
  source: argument
  nullable: false
returns:
  resource: AccountRole
  shape: record
errors:
- not_authorized
- invalid_role
- role_already_exists
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.create_membership_product

```yaml
action: Memberships.create_membership_product
resource: MembershipProduct
domain: Memberships
actor: staff_admin
trigger: []
preconditions: []
state_changes: []
side_effects: []
transaction_boundary: Memberships.create_membership_product runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- creates_membership_product_with_unique_code
- rejects_duplicate_membership_product_code
open_decisions: []
primary_resource: MembershipProduct
mutates_resources:
- MembershipProduct
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: code
  type: string
  required: true
  source: argument
  nullable: false
- name: name
  type: string
  required: true
  source: argument
  nullable: false
- name: description
  type: string
  required: false
  source: argument
  nullable: false
returns:
  resource: MembershipProduct
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.activate_membership_product

```yaml
action: Memberships.activate_membership_product
resource: MembershipProduct
domain: Memberships
actor: staff_admin
trigger: []
preconditions:
- membership_product_is_draft
- membership_product_has_at_least_one_active_plan_or_seed_exception_for_first_config
state_changes: []
side_effects: []
transaction_boundary: Memberships.activate_membership_product runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- archived_membership_product_cannot_be_purchased
open_decisions: []
primary_resource: MembershipProduct
mutates_resources:
- MembershipProduct
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: MembershipProduct
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.create_membership_plan

```yaml
action: Memberships.create_membership_plan
resource: MembershipPlan
domain: Memberships
actor: staff_admin
trigger: []
preconditions: []
state_changes: []
side_effects: []
transaction_boundary: Memberships.create_membership_plan runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- creates_monthly_yearly_and_lifetime_plans
- rejects_invalid_duration_configuration
- duplicate_plan_code_rejected
open_decisions: []
primary_resource: MembershipPlan
mutates_resources:
- MembershipPlan
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: code
  type: string
  required: true
  source: argument
  nullable: false
- name: name
  type: string
  required: true
  source: argument
  nullable: false
- name: duration_type
  type: enum
  required: true
  source: argument
  nullable: false
- name: duration_interval
  type: enum
  required: true
  source: argument
  nullable: false
- name: duration_interval_count
  type: integer
  required: false
  source: argument
  nullable: false
returns:
  resource: MembershipPlan
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.create_benefit_rule

```yaml
action: Memberships.create_benefit_rule
resource: BenefitRule
domain: Memberships
actor: staff_admin
trigger: []
preconditions: []
state_changes: []
side_effects: []
transaction_boundary: Memberships.create_benefit_rule runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- reject_duplicate_rule_code_per_product_or_plan
- benefit_rule_type_is_required
open_decisions: []
primary_resource: BenefitRule
mutates_resources:
- BenefitRule
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: false
  source: argument
  nullable: false
- name: code
  type: string
  required: true
  source: argument
  nullable: false
- name: name
  type: string
  required: true
  source: argument
  nullable: false
- name: benefit_type
  type: enum
  required: true
  source: argument
  nullable: false
- name: benefit_scope
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: BenefitRule
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.activate_benefit_rule

```yaml
action: Memberships.activate_benefit_rule
resource: BenefitRule
domain: Memberships
actor: staff_admin
trigger: []
preconditions:
- parent_membership_product_is_draft_or_active
- parent_membership_plan_is_draft_or_active
- parent_product_and_plan_are_not_archived
state_changes: []
side_effects: []
transaction_boundary: Memberships.activate_benefit_rule runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- benefit_rule_can_activate_for_draft_or_active_plan
- archived_benefit_rule_does_not_create_grants
open_decisions: []
primary_resource: BenefitRule
mutates_resources:
- BenefitRule
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: benefit_rule_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: BenefitRule
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Memberships.activate_membership_plan

```yaml
action: Memberships.activate_membership_plan
resource: MembershipPlan
domain: Memberships
actor: staff_admin
trigger: []
preconditions:
- membership_product_is_active
- at_least_one_active_benefit_rule_exists_for_plan_or_product
- duration_configuration_valid
state_changes: []
side_effects: []
transaction_boundary: Memberships.activate_membership_plan runs in one transaction
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_order_implicitly
- creating_payment_implicitly
tests_required:
- creates_monthly_yearly_and_lifetime_plans
- archived_plan_cannot_be_purchased
open_decisions: []
primary_resource: MembershipPlan
mutates_resources:
- MembershipPlan
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: membership_plan_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: MembershipPlan
  shape: record
errors:
- not_authorized
- duplicate_code
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Catalog.create_membership_offer

```yaml
action: Catalog.create_membership_offer
resource: Offer
domain: Catalog
actor: staff_admin
trigger: []
preconditions:
- membership_product_exists
- membership_plan_exists
state_changes: []
side_effects: []
transaction_boundary: Catalog.create_membership_offer runs in one transaction or read-only
  snapshot context
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_generic_catalog_product
- creating_subscription_provider_object
tests_required:
- rejects_duplicate_offer_code
- offer_remains_membership_only
open_decisions: []
primary_resource: Offer
mutates_resources:
- Offer
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: code
  type: string
  required: true
  source: argument
  nullable: false
- name: name
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: Offer
  shape: record
errors:
- not_authorized
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Catalog.create_membership_price

```yaml
action: Catalog.create_membership_price
resource: Price
domain: Catalog
actor: staff_admin
trigger: []
preconditions:
- billing_interval_matches_membership_plan_duration_for_v0_2_6
state_changes: []
side_effects: []
transaction_boundary: Catalog.create_membership_price runs in one transaction or read-only
  snapshot context
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_generic_catalog_product
- creating_subscription_provider_object
tests_required:
- rejects_second_active_price
- recurring_ready_does_not_create_subscription
open_decisions: []
primary_resource: Price
mutates_resources:
- Price
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: offer_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: currency
  type: string
  required: true
  source: argument
  nullable: false
- name: amount_minor
  type: integer
  required: true
  source: argument
  nullable: false
- name: billing_mode
  type: enum
  required: true
  source: argument
  nullable: false
- name: billing_interval
  type: enum
  required: true
  source: argument
  nullable: false
- name: billing_interval_count
  type: integer
  required: false
  source: argument
  nullable: false
returns:
  resource: Price
  shape: record
errors:
- not_authorized
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Catalog.activate_membership_price

```yaml
action: Catalog.activate_membership_price
resource: Price
domain: Catalog
actor: staff_admin
trigger: []
preconditions:
- price_is_draft
- no_other_active_price_for_offer
state_changes: []
side_effects: []
transaction_boundary: Catalog.activate_membership_price runs in one transaction or
  read-only snapshot context
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_generic_catalog_product
- creating_subscription_provider_object
tests_required:
- rejects_second_active_price
open_decisions: []
primary_resource: Price
mutates_resources:
- Price
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: price_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Price
  shape: record
errors:
- not_authorized
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Catalog.activate_membership_offer

```yaml
action: Catalog.activate_membership_offer
resource: Offer
domain: Catalog
actor: staff_admin
trigger: []
preconditions:
- membership_product_is_active
- membership_plan_is_active
- offer_has_active_price
state_changes: []
side_effects: []
transaction_boundary: Catalog.activate_membership_offer runs in one transaction or
  read-only snapshot context
idempotency: not_required
authorization: staff_admin allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_generic_catalog_product
- creating_subscription_provider_object
tests_required:
- offer_requires_active_plan_and_price
open_decisions: []
primary_resource: Offer
mutates_resources:
- Offer
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: offer_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Offer
  shape: record
errors:
- not_authorized
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Catalog.snapshot_price_for_order_item

```yaml
action: Catalog.snapshot_price_for_order_item
resource: Price
domain: Catalog
actor: system
trigger: []
preconditions:
- price_is_active
state_changes: []
side_effects: []
transaction_boundary: Catalog.snapshot_price_for_order_item runs in one transaction
  or read-only snapshot context
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_generic_catalog_product
- creating_subscription_provider_object
tests_required:
- snapshot_contains_amount_currency_price_and_duration_source
- snapshot_does_not_mutate_price
open_decisions: []
primary_resource: Price
mutates_resources: []
action_type: read
ash_action_kind: read
visibility: public
accepted_arguments:
- name: price_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: OrderItemSnapshot
  shape: value_object
errors:
- not_authorized
- invalid_state
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.create_pending_order

```yaml
action: Commerce.create_pending_order
resource: Order
domain: Commerce
actor: registered_user
trigger: []
preconditions:
- actor_is_authenticated
- actor_email_is_confirmed
- actor_has_no_active_membership_for_membership_product
state_changes: []
side_effects: []
transaction_boundary: creates or reuses one pending order per user per membership_product
idempotency: not_required
authorization: registered_user allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_membership_implicitly
- creating_payment_implicitly
tests_required:
- confirmed_user_can_create_order
- unconfirmed_user_cannot_create_order
- blocks_second_active_membership_per_product
open_decisions: []
primary_resource: Order
mutates_resources:
- Order
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Order
  shape: record
errors:
- not_confirmed
- active_membership_exists_for_product
- pending_order_reused
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Commerce.add_membership_order_item

```yaml
action: Commerce.add_membership_order_item
resource: OrderItem
domain: Commerce
actor: registered_user
trigger: []
preconditions:
- order_belongs_to_actor
- order_is_pending_payment
- offer_and_price_are_active
state_changes: []
side_effects: []
transaction_boundary: creates OrderItem snapshot and recalculates Order totals atomically
idempotency: not_required
authorization: registered_user allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- mutating_live_price
- creating_payment_implicitly
tests_required:
- snapshot_contains_amount_currency_price_and_duration_source
- snapshot_does_not_mutate_price
- rejects_duplicate_membership_item_for_order
open_decisions: []
primary_resource: OrderItem
mutates_resources:
- OrderItem
- Order
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: offer_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: price_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: OrderItem
  shape: record
errors:
- order_not_pending
- offer_not_active
- price_not_active
- duplicate_membership_item
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Commerce.initialize_paystack_transaction

```yaml
action: Commerce.initialize_paystack_transaction
resource: Payment
domain: Commerce
actor: registered_user
trigger: []
preconditions:
- order_belongs_to_actor
- order_has_one_membership_item
- order_total_matches_items
state_changes: []
side_effects:
- call_paystack_initialize_transaction_outside_db_transaction
transaction_boundary: creates Payment and stores Paystack transaction reference before
  returning authorization URL
idempotency: reusing an existing processing payment for the same order is allowed
  if safe
authorization: registered_user allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- activating_membership
- creating_entitlement_grants
- creating_paystack_subscription_in_v0_2_6
tests_required:
- paystack_callback_does_not_activate_membership
- recurring_ready_does_not_create_subscription
open_decisions: []
primary_resource: Payment
mutates_resources:
- Payment
- Order
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: callback_url
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: Payment
  shape: record_with_paystack_authorization_url
errors:
- order_not_payable
- paystack_initialization_failed
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Commerce.submit_order_for_payment

```yaml
action: Commerce.submit_order_for_payment
resource: Order
domain: Commerce
actor: registered_user
trigger: []
preconditions:
- order_belongs_to_actor
- payment_initialized
state_changes: []
side_effects: []
transaction_boundary: sets Order.state to payment_processing after Paystack transaction
  initialization
idempotency: not_required
authorization: registered_user allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- marking_order_paid
- activating_membership
tests_required:
- amount_mismatch_blocks_order_paid
open_decisions: []
primary_resource: Order
mutates_resources:
- Order
- Payment
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Order
  shape: record
errors:
- order_not_pending
- payment_not_initialized
- validation_failed
actor_context:
  authenticated_actor_required: true
notes: []
```


---

## Action: Commerce.ingest_paystack_webhook

```yaml
action: Commerce.ingest_paystack_webhook
resource: PaymentEvent
domain: Commerce
actor: system
trigger: []
preconditions:
- signature_validated_before_processing
- raw_payload_encrypted_or_restricted
- provider_event_identity_computed
state_changes: []
side_effects: []
transaction_boundary: validates signature, stores restricted raw payload plus hash, computes provider_event_identity, and stores or returns existing PaymentEvent atomically
idempotency: unique provider_event_identity prevents duplicate rows and duplicate side effects
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- activating_membership_directly
- creating_grants_directly
- trusting_callback_presence
tests_required:
- duplicate_payment_event_does_not_create_second_row
- invalid_paystack_signature_rejected
- raw_paystack_payload_is_restricted_and_hashed
open_decisions: []
primary_resource: PaymentEvent
mutates_resources:
- PaymentEvent
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: raw_payload
  type: map
  required: true
  source: argument
  nullable: false
- name: paystack_signature
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: PaymentEvent
  shape: record
errors:
- invalid_paystack_signature
- duplicate_event
- unsupported_event_type
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.record_payment_event

```yaml
action: Commerce.record_payment_event
resource: PaymentEvent
domain: Commerce
actor: system
trigger: []
preconditions:
- event_source_known
- raw_payload_hash_present
- provider_event_identity_present
state_changes: []
side_effects: []
transaction_boundary: stores normalized Paystack webhook/Verify evidence idempotently with restricted raw payload evidence
idempotency: unique provider_event_identity prevents duplicates
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- fulfilling_order_directly
- creating_payment_method_directly
- activating_membership_directly
tests_required:
- duplicate_payment_event_does_not_create_second_row
- raw_paystack_payload_is_restricted_and_hashed
open_decisions: []
primary_resource: PaymentEvent
mutates_resources:
- PaymentEvent
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: provider_event_identity
  type: string
  required: true
  source: argument
  nullable: false
- name: event_source
  type: enum
  required: true
  source: argument
  nullable: false
- name: event_type
  type: string
  required: true
  source: argument
  nullable: false
- name: raw_payload_hash
  type: string
  required: true
  source: argument
  nullable: false
- name: signature_valid
  type: boolean
  required: true
  source: argument
  nullable: false
returns:
  resource: PaymentEvent
  shape: record
errors:
- duplicate_event
- invalid_signature
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.mark_payment_succeeded

```yaml
action: Commerce.mark_payment_succeeded
resource: Payment
domain: Commerce
actor: system
trigger: []
preconditions:
- payment_event_is_verified_success
- provider_reference_matches_payment
- amount_matches_order_total
state_changes: []
side_effects: []
transaction_boundary: marks Payment succeeded and sets fulfilment_authority_state to provisional_verify_success or webhook_confirmed according to event_source
idempotency: idempotent when Payment is already succeeded for the same provider transaction reference
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- activating_membership_directly
- creating_entitlement_grants_directly
- ignoring_contradictory_events
tests_required:
- verified_paystack_success_marks_payment_succeeded
- callback_verify_success_can_provisionally_fulfil_order
- webhook_success_confirms_provisional_fulfilment
open_decisions: []
primary_resource: Payment
mutates_resources:
- Payment
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: payment_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: payment_event_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Payment
  shape: record
errors:
- payment_not_found
- event_not_verified
- amount_mismatch
- contradictory_payment_event
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.mark_order_paid

```yaml
action: Commerce.mark_order_paid
resource: Order
domain: Commerce
actor: system
trigger: []
preconditions:
- payment_succeeded
- order_total_matches_payment_amount
state_changes: []
side_effects: []
transaction_boundary: sets Order.state to paid only; stops before membership activation
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- activating_membership
- creating_entitlement_grants
tests_required:
- amount_mismatch_blocks_order_paid
- mark_order_paid_does_not_activate_membership
- mark_order_paid_does_not_create_grants
open_decisions: []
primary_resource: Order
mutates_resources:
- Order
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: payment_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Order
  shape: record
errors:
- order_not_processing
- payment_not_succeeded
- amount_mismatch
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```



---

## Action: Commerce.verify_paystack_transaction

```yaml
action: Commerce.verify_paystack_transaction
resource: PaymentEvent
domain: Commerce
actor: system
trigger: []
preconditions:
- callback_return_received_or_manual_verification_requested
- provider_transaction_reference_present
state_changes: []
side_effects:
- call_paystack_verify_api_outside_db_transaction
transaction_boundary: calls Paystack Verify, records the verification result as a PaymentEvent, and MAY call Commerce.fulfil_paid_order only when provider_status is success
idempotency: provider_transaction_reference plus provider_status plus raw_payload_hash forms deterministic Verify event identity
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- treating_callback_presence_as_success
- fulfilling_on_pending_processing_or_failed_status
- creating_paystack_subscription
tests_required:
- callback_verify_success_can_provisionally_fulfil_order
- verify_pending_does_not_fulfil
- paystack_callback_does_not_activate_membership_without_verify_success
open_decisions: []
primary_resource: PaymentEvent
mutates_resources:
- PaymentEvent
- Payment
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: provider_transaction_reference
  type: string
  required: true
  source: argument
  nullable: false
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: PaymentEvent
  shape: record
errors:
- paystack_verify_failed
- payment_not_found
- provider_status_not_success
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.record_payment_method

```yaml
action: Commerce.record_payment_method
resource: PaymentMethod
domain: Commerce
actor: system
trigger: []
preconditions:
- verified_success_payload_contains_reusable_authorization_metadata
- raw_card_data_absent
state_changes: []
side_effects: []
transaction_boundary: upserts safe Paystack authorization metadata after verified successful payment; SHALL NOT create a subscription
idempotency: unique provider_authorization_code per user prevents duplicates
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- storing_raw_card_data
- creating_paystack_subscription
- charging_payment_method
tests_required:
- stores_paystack_authorization_metadata_without_raw_card_data
- payment_method_does_not_create_subscription
open_decisions: []
primary_resource: PaymentMethod
mutates_resources:
- PaymentMethod
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: payment_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: authorization_metadata
  type: map
  required: true
  source: argument
  nullable: false
returns:
  resource: PaymentMethod
  shape: record
errors:
- missing_authorization_metadata
- raw_card_data_detected
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.fulfil_paid_order

```yaml
action: Commerce.fulfil_paid_order
resource: Order
domain: Commerce
actor: system
trigger: []
preconditions:
- payment_succeeded_or_verified_success
- order_total_matches_payment_amount
- pending_membership_exists
- no_active_membership_for_user_product
state_changes: []
side_effects: []
transaction_boundary: same idempotent fulfilment pipeline used by both Paystack webhook and Paystack Verify; marks payment/order, records PaymentMethod when present, activates Membership, and creates EntitlementGrants atomically where domain invariants require it
idempotency: idempotent on order_id plus payment_id; repeated webhook/Verify replay SHALL not duplicate membership or grants
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_duplicate_membership
- creating_duplicate_grants
- using_separate_callback_and_webhook_fulfilment_logic
- bypassing_membership_actions
tests_required:
- callback_verify_success_can_provisionally_fulfil_order
- webhook_success_confirms_provisional_fulfilment
- duplicate_fulfilment_does_not_duplicate_membership_or_grants
open_decisions: []
primary_resource: Order
mutates_resources:
- Order
- Payment
- PaymentMethod
- Membership
- EntitlementGrant
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: payment_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: payment_event_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Order
  shape: record
errors:
- order_not_payable
- payment_not_succeeded
- amount_mismatch
- active_membership_exists_for_product
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Commerce.move_payment_to_review

```yaml
action: Commerce.move_payment_to_review
resource: Payment
domain: Commerce
actor: system
trigger: []
preconditions:
- contradictory_provider_status_detected
- payment_or_membership_was_provisionally_fulfilled
state_changes: []
side_effects: []
transaction_boundary: moves Payment, Order, Membership, and EntitlementGrant into payment_review where access is blocked pending reconciliation
idempotency: idempotent for same contradiction event
authorization: system allowed by actor permission matrix
audit_requirement: Persisted UTC microsecond timestamps, state fields, source references, and tests SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- silently_cancelling_membership
- leaving_grants_active
- deleting_evidence
tests_required:
- contradictory_event_moves_payment_membership_and_grants_to_review
- payment_review_membership_blocks_access
- payment_review_grant_blocks_access
open_decisions: []
primary_resource: Payment
mutates_resources:
- Payment
- Order
- Membership
- EntitlementGrant
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: payment_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: payment_event_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: reason
  type: string
  required: true
  source: argument
  nullable: false
returns:
  resource: Payment
  shape: record
errors:
- payment_not_found
- contradiction_not_supported
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```

---

## Action: Memberships.create_pending_membership

```yaml
action: Memberships.create_pending_membership
resource: Membership
domain: Memberships
actor: system
trigger: []
preconditions:
- called_only_inside_join_order_orchestration
- no_active_membership_for_user_product
state_changes: []
side_effects: []
transaction_boundary: creates pending Membership linked to order inside VS-002B orchestration
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_grants
- marking_membership_active_before_paid_order
tests_required:
- creates_pending_membership_without_access
- blocks_second_active_membership_per_product
open_decisions: []
primary_resource: Membership
mutates_resources:
- Membership
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: user_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: membership_product_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: membership_plan_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Membership
  shape: record
errors:
- active_membership_exists_for_product
- order_not_pending_or_processing
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Memberships.activate_membership

```yaml
action: Memberships.activate_membership
resource: Membership
domain: Memberships
actor: system
trigger: []
preconditions:
- paid_order_exists
- membership_is_pending_payment
- order_item_duration_snapshot_valid
state_changes: []
side_effects: []
transaction_boundary: VS-002D orchestration SHALL activate Membership and create EntitlementGrants
  in one transaction; both steps commit or roll back together
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- creating_payment
- mutating_order_total
tests_required:
- membership_snapshots_duration_terms
- lifetime_membership_has_no_expiry
- fixed_period_membership_sets_expires_at
open_decisions: []
primary_resource: Membership
mutates_resources:
- Membership
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: membership_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: paid_order_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: Membership
  shape: record
errors:
- order_not_paid
- active_membership_exists_for_product
- invalid_duration_snapshot
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Memberships.create_entitlement_grants

```yaml
action: Memberships.create_entitlement_grants
resource: EntitlementGrant
domain: Memberships
actor: system
trigger: []
preconditions:
- membership_is_active
- active_benefit_rules_exist
- grant_validity_not_longer_than_membership_validity
state_changes: []
side_effects: []
transaction_boundary: VS-002D orchestration SHALL activate Membership and create EntitlementGrants
  in one transaction; both steps commit or roll back together
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- calculating_discounts
- mutating_payment_or_order_state
tests_required:
- benefit_rule_creates_expected_grants
- grant_validity_matches_membership_validity
- archived_benefit_rule_does_not_create_grants
open_decisions: []
primary_resource: EntitlementGrant
mutates_resources:
- EntitlementGrant
action_type: create
ash_action_kind: create
visibility: public
accepted_arguments:
- name: membership_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
returns:
  resource: EntitlementGrant
  shape: list
errors:
- membership_not_active
- no_active_benefit_rules
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Memberships.evaluate_entitlement_access

```yaml
action: Memberships.evaluate_entitlement_access
resource: EntitlementGrant
domain: Memberships
actor: system
trigger: []
preconditions:
- called_through_application_boundary
- checks_membership_state_and_dates
- checks_grant_state_and_dates
state_changes: []
side_effects: []
transaction_boundary: read-only evaluation; scheduled expiry is not trusted as sole
  authority
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- mutating_state
- creating_grants
- calculating_discount_amounts
tests_required:
- access_evaluation_does_not_mutate_state
- expired_grant_blocks_access
- cancelled_membership_blocks_access
open_decisions: []
primary_resource: EntitlementGrant
mutates_resources: []
action_type: read
ash_action_kind: read
visibility: public
accepted_arguments:
- name: user_id
  type: uuid_v7
  required: true
  source: argument
  nullable: false
- name: benefit_type
  type: enum
  required: true
  source: argument
  nullable: false
- name: benefit_scope
  type: string
  required: true
  source: argument
  nullable: false
- name: at
  type: utc_datetime_usec
  required: true
  source: argument
  nullable: false
returns:
  resource: AccessEvaluation
  shape: value_object
errors:
- access_denied
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```


---

## Action: Memberships.expire_due_memberships

```yaml
action: Memberships.expire_due_memberships
resource: Membership
domain: Memberships
actor: system
trigger: []
preconditions:
- system_scheduler_context
state_changes: []
side_effects: []
transaction_boundary: scheduled job marks due Memberships expired and grants expired;
  access checks still defend by date
idempotency: not_required
authorization: system allowed by actor permission matrix
audit_requirement: Persisted timestamps, state fields, source references, and tests
  SHALL provide v0.2.8 audit evidence. AuditEvent SHALL remain deferred.
forbidden_behaviours:
- charging_renewal
- creating_payment
- creating_order
tests_required:
- expire_due_memberships_marks_expired
- expired_grant_blocks_access
open_decisions: []
primary_resource: Membership
mutates_resources:
- Membership
- EntitlementGrant
action_type: update
ash_action_kind: update
visibility: public
accepted_arguments:
- name: now
  type: utc_datetime_usec
  required: true
  source: argument
  nullable: false
returns:
  resource: ExpiryResult
  shape: summary
errors:
- validation_failed
actor_context:
  authenticated_actor_required: false
notes: []
```
