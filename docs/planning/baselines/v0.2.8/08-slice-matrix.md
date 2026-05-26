# 08. Slice Matrix

| Slice | Name | Status | Primary goal | Coding authorization |
|---|---|---|---|---|
| VS-000 | Backend membership commerce tracer | READY_FOR_CODING | Prove the full backend commercial spine using real Ash resources/actions/migrations and fake Paystack adapter fixtures | Authorized |
| VS-001A | Register user with AshAuthentication and consent | NOT_READY | Create confirmed-capable account foundation | Not authorized |
| VS-001B | Login/session/password reset/staff role foundation | NOT_READY | Make actors real and testable | Not authorized |
| VS-002A | Configure membership product, plans, benefits, offer, prices | NOT_READY | Seed/configure Vriendinneklub without hardcoding | Not authorized |
| VS-002B | Create pending membership order | NOT_READY | Confirmed user creates order and pending membership | Not authorized |
| VS-002C | Paystack payment confirmation | NOT_READY | Initialize Paystack, ingest verified success idempotently | Not authorized |
| VS-002D | Activate membership and grants | NOT_READY | Fulfil paid order atomically | Not authorized |
| VS-002E | Evaluate member access | NOT_READY | Read-only defensive access check | Not authorized |
| VS-002F | Recurring readiness and payment method capture | NOT_READY | Capture safe authorization metadata and gate auto-renewing plans | Not authorized |
| VS-003A | Minimal expandable LiveView pages | NOT_READY | Thin pages after backend proof | Not authorized |

Only `VS-000` is coding-authorized in v0.2.8. All other slices require a future slice-specific `/grill-me` and patch before implementation.
