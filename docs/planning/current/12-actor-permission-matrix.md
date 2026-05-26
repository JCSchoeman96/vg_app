# 12. Actor Permission Matrix

Actors are explicit. `system` is an internal execution context, not a user role.

```yaml
action_permissions:
  Accounts.register_user:
    allowed_actors:
    - public_visitor
    primary_actor: public_visitor
  Accounts.confirm_email:
    allowed_actors:
    - public_confirmation_link
    primary_actor: public_confirmation_link
  Accounts.login_user:
    allowed_actors:
    - public_visitor
    primary_actor: public_visitor
  Accounts.request_password_reset:
    allowed_actors:
    - public_visitor
    primary_actor: public_visitor
  Accounts.reset_password:
    allowed_actors:
    - public_visitor
    primary_actor: public_visitor
  Accounts.bootstrap_staff_admin:
    allowed_actors:
    - system
    primary_actor: system
  Accounts.assign_role:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.create_membership_product:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.activate_membership_product:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.create_membership_plan:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.create_benefit_rule:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.activate_benefit_rule:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Memberships.activate_membership_plan:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Catalog.create_membership_offer:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Catalog.create_membership_price:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Catalog.activate_membership_price:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Catalog.activate_membership_offer:
    allowed_actors:
    - staff_admin
    primary_actor: staff_admin
  Catalog.snapshot_price_for_order_item:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.create_pending_order:
    allowed_actors:
    - registered_user
    primary_actor: registered_user
  Commerce.add_membership_order_item:
    allowed_actors:
    - registered_user
    primary_actor: registered_user
  Commerce.initialize_paystack_transaction:
    allowed_actors:
    - registered_user
    primary_actor: registered_user
  Commerce.submit_order_for_payment:
    allowed_actors:
    - registered_user
    primary_actor: registered_user
  Commerce.ingest_paystack_webhook:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.record_payment_event:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.mark_payment_succeeded:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.mark_order_paid:
    allowed_actors:
    - system
    primary_actor: system
  Memberships.create_pending_membership:
    allowed_actors:
    - system
    primary_actor: system
  Memberships.activate_membership:
    allowed_actors:
    - system
    primary_actor: system
  Memberships.create_entitlement_grants:
    allowed_actors:
    - system
    primary_actor: system
  Memberships.evaluate_entitlement_access:
    allowed_actors:
    - system
    primary_actor: system
  Memberships.expire_due_memberships:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.verify_paystack_transaction:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.record_payment_method:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.fulfil_paid_order:
    allowed_actors:
    - system
    primary_actor: system
  Commerce.move_payment_to_review:
    allowed_actors:
    - system
    primary_actor: system
```
