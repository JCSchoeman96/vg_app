# 11 — PR Review Checklist

## Every VS-000C PR

- Does the PR implement only the assigned micro-slice?
- Does it avoid Catalog, Commerce, Paystack, UI, and discount calculation?
- Are resource/action names aligned with the feature pack?
- Are policies explicit and not accidentally public?
- Are tests meaningful and not weakened?
- Are migrations and Ash snapshots generated?
- Does `mix ash.codegen --check` pass?
- Does `mix compile --warnings-as-errors` pass?
- Does `mix test` pass?
- Does the PR body list what changed and what is not included?
- Does the implementation ledger need updating now or after merge?

## VS-000C1 specific

- Product/plan/benefit only?
- Monthly/yearly/lifetime duration rules tested?
- Auto-renewing blocked from live without recurring capability?
- Active plan requires active product and active benefit rule?
- BenefitRule can activate for draft/active non-archived plan?
- Discount access remains eligibility only?

## VS-000C2 specific

- Membership only?
- No EntitlementGrant/access evaluation unless explicitly in C3?
- Activation system-only?
- Duration snapshotting tested?
- Expiry calculation tested, including Jan 31?
- One active membership per user/product enforced?
- Multiple pending memberships allowed?
- Activation idempotent?

## VS-000C3 specific

- EntitlementGrant implemented?
- Grant creation idempotent?
- Access evaluation uses `user_id + benefit_type + benefit_scope`?
- Access evaluation denies pending/expired/payment_review membership?
- Access evaluation denies payment_review/expired grant?
- Access evaluation is read-only and mutates nothing?
