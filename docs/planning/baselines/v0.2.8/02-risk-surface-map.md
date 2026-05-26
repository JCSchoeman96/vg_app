# 02. Risk Surface Map

## P0 risks

| Risk | Why it matters | Hardening in v0.2.7 |
|---|---|---|
| Hardcoding Vriendinneklub everywhere | Blocks multiple future subscription products | Add `MembershipProduct`; Vriendinneklub is configuration, not architecture |
| Treating Paystack callback as proof of payment | Could grant paid access without verified payment | Callback is read-only pending/verifying; webhook/verification delivers value |
| Building recurring subscriptions too early | Expands scope into renewals, invoices, dunning, failed payments | `recurring_ready` metadata only; Paystack subscription lifecycle deferred |
| Unconfirmed email purchases | Causes support/account ownership problems | confirmed email required before order creation |
| Membership expiry based only on scheduler | Access could remain valid if job fails | Defensive access evaluation checks dates every time |
| Staff admin actor without role model | Agents invent permissions | Add `AccountRole`; system remains internal context |
| Consent as loose booleans | Hard to audit and change versions | Add `ConsentRecord` |

## P1 risks

- Paystack event identity may differ by event type; real payload fixtures are required before VS-002C is READY_FOR_CODING.
- Minimal pages can accidentally become CMS/content scope. VS-003A SHALL stay thin.
- Discount entitlement can tempt agents to build discount calculation. This is explicitly forbidden.
