# VG App and Ticketing Platform Integration Recommendation v1.0

Status: `DRAFT_LOCK_CANDIDATE`  
Planning layer: `GM-000 Event Architecture Decision`  
Repo target path: `docs/planning/current/platform/01-vg-app-ticketing-integration-recommendation-v1.md`  
Applies to: `vg_app` and future/companion ticketing app  
Implementation permission: `NONE` — this document is architecture recommendation and scope boundary only.

---

## 1. Recommendation summary

The recommended architecture is:

```text
vg_app and the event/ticketing platform SHOULD be separate repo/apps in the same organisation.
```

`vg_app` SHALL remain the membership-first Christian women’s lifestyle platform.

The ticketing platform SHALL become a dedicated event/ticketing system with its own event, organiser, ticket, attendee, seating, check-in, and reporting logic.

The two systems SHALL integrate through explicit account-linking, benefit eligibility APIs, signed benefit tokens, and a limited sync/reconciliation layer.

The systems SHALL NOT be loosely connected through email matching or manual coupon exports as the primary integration mechanism.

---

## 2. Locked architecture decisions

```text
D-GM000-013:
Event/ticketing SHALL be planned as a separate system/app from vg_app, unless later reversed by explicit architecture decision.
```

```text
D-GM000-014:
vg_app SHALL remain the source of truth for membership, entitlement, and benefit eligibility.
```

```text
D-GM000-015:
ticketing_app SHALL own event, organiser, ticket, attendee, seating/check-in, and event reporting truth.
```

```text
D-GM000-016:
vg_app and ticketing_app SHALL integrate through explicit account-linking, not loose email matching.
```

```text
D-GM000-017:
Benefit redemption across systems SHALL use a hybrid integration model: server-to-server eligibility API, short-lived signed benefit tokens, and periodic sync for cache/reconciliation.
```

```text
D-GM000-018:
Periodic sync SHALL NOT be the authoritative source for live benefit eligibility.
```

```text
D-GM000-019:
Manual coupon export SHALL NOT be the primary membership-benefit integration mechanism.
```

```text
D-GM000-022:
The ticketing platform SHALL live in a separate repo/app in the same organisation.
```

```text
D-GM000-023:
vg_app SHALL own universal platform pillars. ticketing_app SHALL own event-specific operational types. A shared/synced taxonomy subset MAY exist only where needed.
```

---

## 3. Why not build ticketing inside vg_app?

Building event/ticketing inside `vg_app` would initially look simpler, but it carries serious platform risk.

Event ticketing has its own complexity:

- organisers
- organiser dashboards
- organiser-specific reporting
- attendee lists
- financial payout reports
- refund request workflows
- event creation/editing
- ticket types
- capacity rules
- seating or VIP allocation
- scan/check-in access
- staff permissions
- third-party event boundaries
- travel/cruise/package edge cases

If this scope is absorbed into `vg_app` too early, it will likely dominate the architecture and slow down the core Vriendinneklub/member platform.

The business ranking places Vriendinneklub subscriptions first and events/ticketing second. That means events matter, but they should not swallow the membership platform.

---

## 4. System ownership boundaries

## 4.1 vg_app owns

`vg_app` SHALL own:

```text
user identity root / account root
profile basics
consent records
membership products
membership plans
membership lifecycle
subscription truth
entitlement truth
benefit rule truth
benefit eligibility truth
Vriendinneklub status
Voelgoed Netwerk status
universal platform pillars
member-only content access
learning/content/product access decisions
partner benefit eligibility
```

## 4.2 ticketing_app owns

`ticketing_app` SHALL own:

```text
event organiser truth
event operational data
event creation/editing
event pages or event storefront
ticket products/ticket types
ticket inventory/capacity
reserved seating, tables, VIP blocks, or check-in mechanics
orders/tickets for events, if ticketing commerce is local
attendee data
check-in/scanning
organiser dashboard
organiser reporting
financial payout reports
refund request workflow
```

## 4.3 Shared boundary

The shared boundary SHALL include:

```text
linked account identity
membership eligibility lookup
benefit eligibility decision
short-lived signed benefit proof
event summary import/export, if needed
shared platform pillar taxonomy subset
reporting/analytics exchange, if needed
```

---

## 5. Integration model

Recommended model:

```text
vg_app
  owns membership/entitlement/benefit truth

 ticketing_app
  owns event/ticket/attendee/organiser truth

 integration boundary
  uses explicit account linking
  uses real-time eligibility API
  uses short-lived signed benefit tokens
  uses periodic sync only for cache/reconciliation/reporting
```

Authority order:

```text
1. vg_app membership/entitlement state = source of truth
2. ticketing_app server-to-server eligibility API call = real-time decision
3. signed benefit token = short-lived checkout/session proof
4. periodic sync = cache/reporting/reconciliation/fallback display
5. manual coupon export = emergency fallback only, not architecture
```

---

## 6. Account-linking model

Because the systems are separate, the integration SHALL NOT rely on loose email matching.

Email matching may help discover a likely link, but it SHALL NOT be the proof of account identity.

Recommended linked-account record:

```yaml
linked_account:
  id: uuid_v7
  vg_app_user_id: uuid_v7
  ticketing_user_id: uuid_v7
  ticketing_app_account_ref: string
  link_method: enum
  status: enum[pending, linked, revoked]
  verified_email_at: utc_datetime_usec nullable
  linked_at: utc_datetime_usec nullable
  revoked_at: utc_datetime_usec nullable
  inserted_at: utc_datetime_usec
  updated_at: utc_datetime_usec
```

Potential link methods:

```text
email_verification
signed_login_handoff
admin_link
future_sso
```

Minimum rule:

```text
A ticketing user SHALL NOT receive member benefits merely because their email resembles a vg_app user email.
```

---

## 7. Benefit eligibility API

The ticketing platform SHOULD ask `vg_app` for benefit eligibility.

Example request concept:

```json
{
  "ticketing_user_id": "tusr_123",
  "linked_account_id": "link_123",
  "benefit_type": "event_vip_eligibility",
  "benefit_scope": "event:evt_123:vriendinneklub-vip",
  "context": {
    "event_id": "evt_123",
    "ticket_type_id": "vip_01",
    "requested_at": "2026-05-26T20:00:00Z"
  }
}
```

Example response concept:

```json
{
  "allowed": true,
  "reason": "active_entitlement_grant",
  "vg_app_user_id": "usr_123",
  "membership_product_code": "vriendinneklub",
  "benefit_type": "event_vip_eligibility",
  "benefit_scope": "event:evt_123:vriendinneklub-vip",
  "valid_until": "2026-06-26T20:00:00Z",
  "decision_id": "bed_123"
}
```

The API response SHOULD answer eligibility. It SHOULD NOT force the ticketing platform to duplicate membership logic.

---

## 8. Signed benefit tokens

For checkout, early-bird booking, VIP seat access, or limited-time offers, `vg_app` MAY issue a short-lived signed benefit token.

The token SHOULD prove eligibility for a specific audience and scope.

Recommended token claims:

```text
iss = vg_app
aud = ticketing_app
sub = vg_app_user_id
ticketing_user_id or linked_account_id
membership_product_code
benefit_type
benefit_scope
allowed
issued_at
expires_at
jti / nonce
correlation_id
signature
```

Important rule:

```text
The token proves eligibility. The ticketing app still owns ticket pricing, capacity, seat allocation, order rules, and final ticket issuance.
```

Tokens SHOULD be short-lived. Long-lived benefit tokens create stale access risk.

---

## 9. Periodic sync

Periodic sync MAY be used for:

- faster UI display
- organiser reports
- analytics
- fallback read models
- reducing API calls
- reconciliation
- support diagnostics

Periodic sync SHALL NOT be the authoritative source for live benefit eligibility.

Examples of data that MAY be synced:

```text
linked account status
membership product codes
coarse active/inactive member flag
benefit summary cache
universal platform pillar terms
non-sensitive event summary references back into vg_app
```

Sensitive membership decisions SHOULD still be checked against `vg_app` at checkout or benefit redemption time.

---

## 10. SSO recommendation

Full SSO is not required as the first integration step.

Recommended sequence:

```text
Phase 1: explicit account-linking
Phase 2: server-to-server eligibility API
Phase 3: signed benefit tokens
Phase 4: periodic sync/reconciliation
Phase 5: shared SSO / OIDC-style login if both apps mature
```

Why SSO should not be first:

- SSO solves login UX.
- SSO does not, by itself, solve membership eligibility.
- SSO does not solve VIP seating rules.
- SSO does not solve discount eligibility.
- SSO does not solve revocation after membership expiry.

The deeper problem is not login.

The deeper problem is:

```text
Which system owns membership truth?
```

Answer:

```text
vg_app owns membership truth.
```

---

## 11. Taxonomy sharing

`vg_app` SHALL own universal platform pillars.

Examples:

```text
Nuwe Jy
Ouerskap
Self
Geloof
Huwelik
Finansies
```

`ticketing_app` SHALL own event-specific operational taxonomy.

Examples:

```text
event_type
ticket_type
venue_type
seat_section
check_in_status
organiser_type
capacity_model
```

A shared/synced subset MAY exist only where needed.

Example:

```text
A Voelgoed-owned event may be tagged as Geloof and Huwelik from vg_app platform pillars.
The same event may also be event_type = Vroue-oggend inside ticketing_app.
```

Critical rule:

```text
Universal platform pillars SHALL NOT be treated as the same taxonomy as ticketing operational types.
```

---

## 12. Event-linked benefits

`vg_app` MAY define benefits such as:

```text
event_vip_eligibility
event_early_booking_eligibility
event_discount_eligibility
event_member_only_access
event_waitlist_priority
```

`ticketing_app` MAY consume these benefit decisions to:

- allow access to a member-only event
- show early-bird ticket types
- unlock VIP ticket options
- validate discount eligibility
- prioritise waitlist access

However, ticketing_app SHALL own:

- whether the event has capacity
- whether a specific ticket type is available
- whether a seat/table/cabin/package option is available
- whether a ticket may be issued
- check-in validation

---

## 13. Failure modes and required protections

### 13.1 Account linking failure

Risk:

```text
A user believes they linked accounts but ticketing cannot verify benefits.
```

Protection:

- explicit linked-account status
- support-visible diagnostics
- clear user-facing link state
- retry/relink workflow

### 13.2 Stale membership status

Risk:

```text
Ticketing cache says active, but membership expired or moved to payment_review.
```

Protection:

- real-time eligibility API check at benefit redemption
- short token expiry
- periodic reconciliation

### 13.3 Shared coupon abuse

Risk:

```text
A member code is shared publicly.
```

Protection:

- coupons not used as primary integration
- eligibility tied to linked account and signed token

### 13.4 Partner/system outage

Risk:

```text
vg_app eligibility API is unavailable during ticket checkout.
```

Protection options:

- fail closed for high-value or member-only benefits
- allow stale cache only for low-risk display
- retry queue
- user-facing “benefit verification unavailable” state

### 13.5 Duplicate identity

Risk:

```text
Same person has different accounts in both systems.
```

Protection:

- explicit linking
- email verification
- manual support merge/link tools later
- audit trail

---

## 14. Security and audit requirements

The integration SHALL eventually include:

- server-to-server authentication
- scoped API credentials
- signed token verification
- token expiry
- replay protection through nonce/jti
- correlation IDs
- audit logs for benefit decisions
- audit logs for account linking and unlinking
- audit logs for manual support overrides

No production benefit integration should rely only on frontend trust.

---

## 15. Recommended future integration feature group

```text
FEAT-0010 — Event Integration Foundation
```

Potential roadmap:

```text
FEAT-0010A — Linked account model and manual link flow
FEAT-0010B — Benefit eligibility API contract
FEAT-0010C — Signed benefit token contract
FEAT-0010D — Taxonomy subset sync contract
FEAT-0010E — Event summary/read-model sync
FEAT-0010F — Support diagnostics and reconciliation
```

Each should be grilled separately before implementation.

---

## 16. Recommended ticketing platform feature group

```text
FEAT-TKT-0001 — Ticketing Platform Foundation
```

Possible high-level roadmap:

```text
TKT-0001A — Event organiser model
TKT-0001B — Event creation/editing
TKT-0001C — Ticket type/capacity model
TKT-0001D — Event checkout/payment
TKT-0001E — Attendee data capture
TKT-0001F — Ticket issuance
TKT-0001G — Organiser reporting
TKT-0001H — Check-in/scanning
TKT-0001I — vg_app account-link integration
TKT-0001J — vg_app member benefit integration
```

This belongs in the ticketing repo/app, not automatically in `vg_app`.

---

## 17. What not to build now

This recommendation SHALL NOT unlock:

- full SSO
- full event ticketing inside `vg_app`
- organiser dashboard inside `vg_app`
- ticket checkout inside `vg_app`
- ticket scanner inside `vg_app`
- payout accounting inside `vg_app`
- event refund engine inside `vg_app`
- complex seating inside `vg_app`
- manual coupon export as primary member-benefit system

---

## 18. Final recommendation

Use two apps, one organisation, explicit contracts.

```text
vg_app = membership, content, learning, commerce, entitlement, benefits, community.

ticketing_app = events, organisers, tickets, attendees, check-in, event reporting.

integration = linked accounts, eligibility API, signed benefit tokens, limited sync.
```

This gives `vg_app` room to become the Vriendinneklub-centred lifestyle platform without being swallowed by event-ticketing complexity, while still allowing member benefits to drive event conversion and value.

