# 01. Assumption Register

## Locked assumptions for v0.2.7

| ID | Assumption | Status | Consequence |
|---|---|---|---|
| A-001 | Users are real authenticated accounts | LOCKED | AshAuthentication boundary required |
| A-002 | Email confirmation is required before purchase | LOCKED | Commerce order creation rejects unconfirmed users |
| A-003 | Staff admin is a real role | LOCKED | AccountRole required |
| A-004 | system is internal execution context only | LOCKED | system is not stored as a user role |
| A-005 | Vriendinneklub is the first MembershipProduct | LOCKED | no hardcoded club-specific resource names |
| A-006 | Multiple membership products must be possible | LOCKED | MembershipProduct required |
| A-007 | Monthly/yearly/lifetime terms must be configurable | LOCKED | MembershipPlan and Membership duration snapshots required |
| A-008 | Paystack is the first gateway target | LOCKED | Paystack webhook/verification boundary required |
| A-009 | Paystack callback does not deliver value | LOCKED | callback pages show pending/verifying only |
| A-010 | Recurring billing is schema-ready but not implemented | LOCKED | recurring_ready allowed, subscription lifecycle deferred |
| A-011 | Discount entitlement is eligibility only | LOCKED | no discount calculation in v0.2.7 |

## Still open after v0.2.7

| ID | Open question | Blocks coding? |
|---|---|---|
| O-001 | Exact Paystack payload fields and event identity derivation must be verified against real test payloads before coding webhook parsing. | YES for VS-002C |
| O-002 | Exact LiveView page copy and UX can be decided later. | NO for backend tracer |
| O-003 | Exact first membership prices can be seeded later. | NO if amount fixtures are supplied in tests |
