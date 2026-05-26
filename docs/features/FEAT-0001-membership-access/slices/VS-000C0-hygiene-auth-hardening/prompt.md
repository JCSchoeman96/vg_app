# Coding Prompt — VS-000C0

Implement VS-000C0 only.

## Goal

Prepare the repo for VS-000C Memberships work by fixing hygiene/auth issues only.

## Allowed

- Normalize shell script line endings if needed.
- Fix `make status` if broken.
- Harden `AccountRole` read policy from broad read to owner/staff_admin/system where practical.
- Add/update tests proving role read policy if touched.
- Update implementation ledger if assigned.

## Forbidden

- MembershipProduct
- MembershipPlan
- BenefitRule
- Membership
- EntitlementGrant
- Catalog
- Commerce
- Paystack
- UI

## Required checks

```bash
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

Open PR:

```text
VS-000C0: Hygiene and auth hardening
```
