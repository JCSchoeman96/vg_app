# VG App Platform Specification v1.0

Status: `DRAFT_LOCK_CANDIDATE`  
Planning layer: `GM-000 Platform Scope`  
Repo target path: `docs/planning/current/platform/00-vg-app-platform-spec-v1.md`  
Applies to: `vg_app`  
Implementation permission: `NONE` — this document is platform-scope planning law only. It does not make any feature coding-ready.

---

## 1. Purpose

This document defines the high-level platform scope, business direction, capability map, feature groups, tracer bullets, sequencing, scope boundaries, and major architectural decisions for `vg_app`.

It exists to prevent coding agents and planning agents from treating isolated feature work, especially Memberships, Commerce, LMS, or Events, as disconnected systems.

The platform SHALL be planned as one coherent business system, but implementation SHALL still happen through narrow, grilled, coding-ready feature packs and vertical slices.

---

## 2. Source-of-truth role

This document is a platform-scope planning document.

Authority order for implementation remains:

```text
1. Merged code on main
2. AGENTS.md
3. Assigned Linear issue / assigned coding prompt
4. Repo feature pack under docs/features/**
5. docs/planning/current/**
6. PR body / chat summary
```

If this document conflicts with current code, AGENTS.md, a locked feature pack, or an assigned slice prompt, coding agents SHALL stop and report `BLOCKED`.

This document SHALL NOT be used by coding agents as direct implementation scope. Coding agents may only implement from an assigned, grilled, coding-ready slice pack.

---

## 3. Platform identity

`vg_app` SHALL be a membership-first Christian women’s lifestyle and community platform.

The platform serves women roughly aged 30 to 55 through:

- free public content
- paid content
- subscriber-only content
- memberships
- benefits and perks
- courses and challenges
- webinars and recordings
- podcasts and online shows
- digital products
- physical products
- event access and event-linked benefits
- competitions
- professional networking
- partner offers

The platform’s strategic centre is not a shop, not an LMS, and not a ticketing system.

The strategic centre is:

```text
A unified account and membership relationship that unlocks benefits, access, community, and recurring revenue.
```

---

## 4. Business engine ranking

Current target ranking:

```text
1. Voelgoed Vriendinneklub subscriptions
2. Events / ticketing
3. Advertising / sponsorship / promotions
4. Courses / challenges
5. Voelgoed Netwerk subscriptions
6. Physical / digital product sales
```

Planning implication:

- Membership and entitlement infrastructure SHALL come before broad shop/product complexity.
- Commerce is important, but it exists to support subscriptions, access, paid learning, products, events, and sponsor-paid access.
- Product catalogue design SHALL NOT dominate the early architecture.

---

## 5. Core north-star decision

```text
D-GM000-001:
Platform identity SHALL be membership-first Christian women’s lifestyle/community platform.
```

```text
D-GM000-002:
Vriendinneklub SHALL be the primary recurring revenue and growth engine.
```

```text
D-GM000-003:
One account SHALL be the long-term goal across content, learning, commerce, memberships, events, competitions, and community.
```

```text
D-GM000-004:
Benefits and entitlements SHALL be central cross-platform infrastructure.
```

Everything on the platform SHOULD support one or more of:

- membership conversion
- membership retention
- member value
- audience trust
- content engagement
- event participation
- partner/sponsor value
- revenue diversification

---

## 6. Account and access model

A single user account SHALL eventually unlock most of the platform.

The platform SHALL support a mixed access model:

```text
free public access
paid once-off access
subscriber-only access
member benefit access
limited-time access
lifetime access
admin-granted access
sponsor-paid access
```

A user MAY:

- read free content
- listen to free podcasts
- watch free broadcasts
- buy a course
- purchase event tickets
- hold Vriendinneklub membership
- hold Voelgoed Netwerk membership
- access subscriber-only content
- receive benefit eligibility
- participate in competitions

Access SHALL be evaluated through explicit entitlement and benefit rules, not scattered ad-hoc checks.

---

## 7. Membership products

### 7.1 Vriendinneklub

`Vriendinneklub` SHALL be the primary membership product and growth engine.

Planned benefit types include:

- member-only content
- free course/challenge access where explicitly granted
- early-bird booking eligibility
- VIP seating eligibility
- community access
- future partner benefits
- future cross-platform discount eligibility

### 7.2 Voelgoed Netwerk

`Voelgoed Netwerk` SHALL be a separate membership product from Vriendinneklub.

It is positioned as a Christian-values-aligned professional women’s network.

Planned benefit areas include:

- professional directory access
- business profiles
- private content
- discussion groups
- live networking events
- resource library

### 7.3 Multiple memberships

A user MAY hold multiple membership products at the same time.

Examples:

```text
User A has active Vriendinneklub membership.
User A also has active Voelgoed Netwerk membership.
```

### 7.4 Plan duration

The long-term platform SHALL support:

- monthly plans
- yearly plans
- lifetime plans

However, early tracer bullets MAY start with monthly only.

Lifetime plans SHALL be treated carefully because they create indefinite business commitments. Public lifetime sale SHOULD remain a deliberate business decision, not an accidental default.

---

## 8. Entitlements and benefits

Entitlements and benefits are the platform heart.

Correct mental model:

```text
MembershipProduct
  |> MembershipPlan
  |> BenefitRule
  |> Membership
  |> EntitlementGrant / BenefitEligibility
  |> Access or benefit decision
```

The platform SHALL NOT implement membership checks as scattered local conditionals across content, LMS, events, commerce, or community.

### 8.1 Entitlement examples

```text
member_content_access
course_access
challenge_access
webinar_access
digital_download_access
community_access
professional_network_access
competition_participation_access
```

### 8.2 Benefit eligibility examples

```text
event_vip_eligibility
event_early_booking_eligibility
event_discount_eligibility
shop_discount_eligibility
partner_offer_eligibility
sponsor_paid_access_eligibility
```

### 8.3 Rule

Entitlement grants decide whether a user may access something.

Benefit eligibility decides whether a user qualifies for a perk, discount, VIP option, early-bird window, partner benefit, or special offer.

Discount calculation itself MAY be a later capability and SHALL NOT be assumed to exist just because discount eligibility exists.

---

## 9. Platform taxonomy

The platform SHALL support taxonomy, categories, and subcategories, but not as one undifferentiated category table.

Taxonomy SHALL be typed by scheme.

Recommended conceptual model:

```text
TaxonomyScheme
TaxonomyTerm
TaxonomyAssignment
```

### 9.1 TaxonomyScheme examples

```text
platform_pillar
event_type
content_format
learning_format
commerce_product_type
access_model
campaign
audience_segment
partner_category
```

### 9.2 Universal platform pillars

`vg_app` SHALL own the universal platform pillars.

Initial universal pillars:

```text
Nuwe Jy
Ouerskap
Self
Geloof
Huwelik
Finansies
```

These pillars MAY apply to:

- articles
- podcasts
- videos
- shows
- courses
- challenges
- webinars
- products
- campaigns
- events, where synced/integrated with the ticketing app

### 9.3 Event-type taxonomy

Event-type taxonomy SHALL be separate from universal platform pillars.

Examples:

```text
Fees
Mark
Funksie
Vroue-oggend
Vertoning
Produksie
Werkswinkel
Praatjie
Uitsending
Reis
Toer
Sport
Gholfdag
Donasie
Kompetisie
```

### 9.4 Access model taxonomy

Examples:

```text
free
paid
member_only
subscriber_discount
vip
early_bird
limited_capacity
sponsor_supported
```

### 9.5 Critical taxonomy rule

```text
D-GM000-020:
Universal platform pillars, event types, learning formats, product types, and access models SHALL NOT be collapsed into one undifferentiated category model.
```

A backend admin interface MAY allow staff to create categories and subcategories, but each term SHALL belong to a `TaxonomyScheme` with allowed target types.

---

## 10. Content and media

The platform SHALL support free and gated content.

Initial content types:

- articles/text
- audio
- video
- podcasts
- member-only content
- free public content

Future media/show structure:

```text
Show
  |> Season
  |> Episode
```

Voelgoed Live and Twintig20 MAY initially be represented by landing pages and video content, but the long-term model SHOULD support show/season/episode structure.

Content access SHALL be entitlement-aware.

Examples:

```text
Public article: free access
Member article: Vriendinneklub entitlement required
Purchased replay: purchase entitlement required
Course recording: learning enrollment entitlement required
```

---

## 11. Learning / LMS / challenges

The platform SHALL eventually support:

- courses
- challenges
- webinars
- recordings
- replays
- downloadable workbooks/resources
- cohort-based access
- self-paced access
- limited-time access
- lifetime access
- free access
- admin-granted access
- membership-perk access
- subscription access

### 11.1 Challenge rule

Challenges are not merely courses.

A cohort-based challenge MAY include:

- shared start date
- shared end date
- day/week unlock rhythm
- participation window
- content access window
- replay or recording access

The system SHALL also be able to support self-paced versions.

### 11.2 Access rule

Learning access SHALL be entitlement-based.

Examples:

```text
Buy once + lifetime access
Buy once + limited-time challenge access
Membership perk access
Subscription access
Free access
Admin-granted access
```

---

## 12. Commerce and product scope

The platform SHALL eventually support:

- once-off card payments
- EFT/manual payments
- recurring card subscriptions
- instalments/deposits
- free orders
- coupons/discounts
- sponsor-paid access
- manual refunds first
- self-service refunds later

Product types eventually include:

- physical products
- eBooks
- digital downloads
- course purchases
- event tickets or event-linked external purchases
- bundles
- donations
- competition entries
- gift cards/vouchers later

### 12.1 Marketplace decision

There SHALL be no third-party shop/vendor marketplace in v1.

Third-party selling complexity is reserved for events/ticketing, not the shop.

### 12.2 Bundle warning

Cross-domain bundles are an ultimate goal, but SHALL be deferred until core entitlement, commerce, and access models are stable.

Example deferred bundle:

```text
course + eBook + event ticket + membership discount
```

---

## 13. Events and ticketing

Events and ticketing are strategically important, but full event ticketing SHALL be planned as a separate repo/app in the same organisation unless explicitly reversed by a future architecture decision.

`vg_app` SHALL NOT absorb full ticketing complexity early.

The platform still needs event-linked capability because events are the second business engine.

### 13.1 Event ownership models

Planned event ownership models:

- Voelgoed-owned events
- third-party organiser events sold by Voelgoed

### 13.2 Event capabilities, owned by ticketing app

The separate ticketing app SHOULD own:

- organiser profile
- organiser dashboard
- event creation by organiser
- ticket sales reporting
- attendee list access
- financial payout report
- refund request workflow
- scan/check-in access
- marketing page editing
- seating / VIP / capacity mechanics
- event operational taxonomy

### 13.3 vg_app event role

`vg_app` SHALL own:

- membership truth
- entitlement truth
- benefit eligibility truth
- universal platform pillars
- member benefit definitions
- partner/member value narrative
- event-linked benefit eligibility for members

`vg_app` MAY display event-linked promotional content or consume event summaries later, but SHALL NOT become the operational ticketing authority unless the architecture decision changes.

---

## 14. Travel, cruises, and tours

Cruises/tours SHALL be treated as package/travel workflows, not ordinary event tickets.

MSC handles cabin inventory and core cruise booking mechanics.

The platform may at most support package sales, package interest, and booking coordination with MSC.

Relevant data may include:

- passport details
- ID numbers
- date of birth
- cabin type
- emergency contact
- deposit/payment schedule

Travel-specific workflows SHALL be deferred until after the platform/ticketing boundary is stable.

---

## 15. Competitions and voting

Competitions such as `Inspirasievrou van die Jaar` are a separate high-risk capability.

The eventual model may include:

- nomination
- entry form
- paid entry
- free entry
- public voting
- judging panel
- finalists
- winner event
- sponsor involvement

Voting may be free or paid. Paid voting may occur externally, for example by SMS, and does not have to be owned by `vg_app` initially.

Fraud controls MAY include:

- one vote per email
- one vote per account
- one vote per phone
- rate limiting
- IP/device checks
- email verification
- paid vote receipt
- manual review
- audit export

Competitions SHALL NOT be implemented without a dedicated feature grill-me and fraud-control design.

---

## 16. Community / Voelgoed Netwerk

Voelgoed Netwerk SHALL be a professionally focused, Christian-values-aligned community/network offering.

Potential capabilities:

- directory of professional women
- business profiles
- private content
- discussion groups
- live networking events
- resource library

Messaging/DMs and heavy community moderation SHALL be deferred unless explicitly planned, because they create major safety, moderation, and operational scope.

---

## 17. Marketing, sponsorship, and partner benefits

Advertising, sponsorship, and promotions are the third-ranked business engine.

The platform SHALL eventually support partner benefits and sponsored access patterns, but partner benefit redemption must not weaken membership truth.

Examples:

- sponsor-paid access
- partner discount eligibility
- member-only partner offers
- promotional campaigns
- campaign conversion tracking

Partner benefits SHALL integrate through the benefit/entitlement model where possible.

---

## 18. Admin, support, and manual overrides

Planned runtime actor types:

```text
super_admin
platform_admin
support_agent
finance_admin
content_editor
learning_admin
event_organiser
event_staff
community_admin
competition_admin
system
```

`developer` SHOULD NOT be treated as a normal in-app business actor unless explicitly required. Developer access is operational/repo/infrastructure access, not default domain authority.

Manual overrides eventually include:

- grant access
- revoke access
- extend membership
- resend ticket
- change attendee details
- move user to payment_review
- issue refund
- cancel ticket
- change event capacity
- override discount
- merge duplicate accounts

Every manual override SHALL eventually be auditable with:

```text
actor
reason
timestamp
before/after state
affected user/order/membership/ticket
correlation id
```

Full audit implementation may be deferred, but no serious admin override feature should ship without auditability.

---

## 19. Reporting and analytics

Top priority reports:

```text
1. membership MRR / ARR
2. event sales
3. content engagement
4. eCommerce sales
5. refunds / cancellations
```

Reporting SHALL read business truth. It SHALL NOT become business truth.

---

## 20. Recommended feature group map

```text
FEAT-0000 — Accounts, Profiles, Consent, Roles Foundation
FEAT-0001 — Membership Access Foundation
FEAT-0002 — Platform Taxonomy Foundation
FEAT-0003 — Content & Media Foundation
FEAT-0004 — Entitlement & Benefit Eligibility Foundation
FEAT-0005 — Commerce / Order / Payment Foundation
FEAT-0006 — Subscription Billing & Renewal Foundation
FEAT-0007 — Learning / Courses / Challenges Foundation
FEAT-0008 — Digital Product Access Foundation
FEAT-0009 — Physical Product Commerce Foundation
FEAT-0010 — Event Integration Foundation
FEAT-0011 — Event Ticketing System, companion repo/app
FEAT-0012 — Voelgoed Netwerk Community Foundation
FEAT-0013 — Competitions & Voting Foundation
FEAT-0014 — Shows / Podcasts / Online TV Foundation
FEAT-0015 — Partner Benefits & Sponsorship Foundation
FEAT-0016 — Admin Support & Manual Overrides
FEAT-0017 — Reporting & Analytics Foundation
FEAT-0018 — Travel / Cruise / Tour Packages Foundation
```

These feature groups are roadmap containers only. They are not automatically coding-ready.

---

## 21. Recommended tracer bullets

### TB-001 — Membership access without commerce

```text
Vriendinneklub product
→ plan
→ benefit rule
→ membership
→ entitlement grant
→ access evaluation true/false
```

### TB-002 — First paid Vriendinneklub membership

```text
user
→ order
→ Paystack once-off payment
→ payment event
→ fulfilment
→ membership activation
→ grants
→ access allowed
```

### TB-003 — Member-only content access

```text
free user denied
active Vriendinneklub member allowed
expired member denied
```

### TB-004 — Learning challenge access

```text
user buys challenge
→ cohort access opens
→ day/week content unlocks
→ access closes
→ self-paced version behaves differently
```

### TB-005 — Digital product purchase access

```text
user buys eBook/recording
→ payment succeeds
→ digital access/download entitlement granted
```

### TB-006 — Benefit eligibility across external event ticketing

```text
active Vriendinneklub member
→ ticketing app checks eligibility
→ VIP/early-bird/discount eligibility returned
→ ticketing app does not duplicate membership truth
```

### TB-007 — Event ticket purchase in ticketing system

```text
organiser event
→ ticket purchase
→ attendee capture
→ ticket issued
→ organiser sees only own event data
```

### TB-008 — Recurring renewal

```text
monthly/yearly subscription
→ renewal payment succeeds
→ membership extends
→ failed payment moves to correct access state
```

### TB-009 — Competition entry and voting

```text
entry
→ voting
→ fraud limits
→ audit export
→ finalists/winner workflow
```

### TB-010 — Voelgoed Netwerk

```text
professional member subscribes
→ business profile/directory access
→ private content/community access
→ expired member denied
```

---

## 22. Recommended development sequence

### Phase 0 — Platform law and roadmap

- platform scope map
- capability map
- feature group roadmap
- tracer bullet map
- event-system architecture decision
- taxonomy decision

### Phase 1 — Account + Membership + Entitlement foundation

- accounts
- profiles
- consent
- roles
- Vriendinneklub product/plan/benefit
- membership lifecycle
- entitlement grants
- access evaluation

### Phase 2 — Content/media access

- free content
- member-only content
- video/audio/text basics
- show/episode light model

### Phase 3 — Commerce/payment foundation

- orders
- payments
- Paystack once-off
- free orders
- manual/EFT handling
- sponsor-paid access
- payment review

### Phase 4 — Subscription billing

- monthly/yearly recurring
- renewals
- failed payment state
- cancellation
- manual admin support

### Phase 5 — Learning/challenges

- courses
- challenges
- cohorts
- self-paced access
- webinars/recordings/replays

### Phase 6 — Digital/physical products

- eBooks
- digital downloads
- physical product sales
- shipping later
- bundles later

### Phase 7 — Event integration / ticketing boundary

- account linking
- benefit eligibility API
- signed benefit tokens
- event summary integration if needed
- separate ticketing app planning

### Phase 8 — Community / Voelgoed Netwerk

- directory
- business profiles
- private content
- discussion groups later
- networking events

### Phase 9 — Competitions and voting

- entries
- public voting
- fraud controls
- audit export
- winner event

### Phase 10 — Reporting and analytics

- MRR/ARR
- event sales
- content engagement
- eCommerce sales
- refunds/cancellations

---

## 23. Scope boundaries

The following SHALL remain deferred until specifically grilled, planned, and activated:

- full event ticketing inside `vg_app`
- full ticketing organiser multi-tenancy inside `vg_app`
- Paystack recurring subscription lifecycle
- dunning / failed renewal recovery
- upgrade/downgrade
- proration
- self-service refunds
- self-service cancellation
- complex bundles
- third-party shop/vendor marketplace
- full LMS implementation
- full community discussion/messaging
- competition voting fraud engine
- cruise/travel package engine
- full reporting warehouse

---

## 24. Final platform rule

```text
Broad platform roadmap MAY guide sequencing.
Only grilled feature packs and coding-ready slice packs MAY guide implementation.
```

