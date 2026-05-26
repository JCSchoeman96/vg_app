# 03. Workflow Inventory

## Active v0.2.7 Workflows

1. Register account with AshAuthentication and required consent.
2. Confirm email before purchase.
3. Bootstrap/assign staff admin role.
4. Configure membership product, monthly/yearly/lifetime plans, benefit rules, offer, and price.
5. Create pending membership order for a confirmed user.
6. Initialize Paystack transaction.
7. Return from Paystack callback and run server-side Verify where needed.
8. Ingest Paystack webhook and store restricted raw evidence plus hash.
9. Use one idempotent fulfilment pipeline for webhook success and Verify success.
10. Record safe Paystack authorization metadata as PaymentMethod.
11. Activate membership and grants atomically through fulfilment.
12. Evaluate access from state and validity dates.
13. Expire due memberships through scheduled job while access evaluation remains defensive.

## Explicitly Deferred

Automatic recurring billing, Paystack subscription lifecycle, renewal invoices, failed renewal recovery, dunning, upgrade/downgrade, proration, refunds, discount calculation, events, learning, community implementation, content CMS implementation, and full admin UI.
