# VS-001A — Register User With AshAuthentication and Consent

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `User`
- `UserProfile`
- `ConsentRecord`

## Actions involved
- `Accounts.register_user`
- `Accounts.confirm_email`

## Blocking decisions
- none

## Required tests
- `registers_user_with_required_profile_and_consents`
- `terms_and_privacy_consent_required`
- `marketing_consent_optional_and_separate`
- `confirmed_user_can_create_order`
- `unconfirmed_user_cannot_create_order`

## Slice law
Registration SHALL create User, UserProfile, and required ConsentRecords atomically.

Email confirmation SHALL be required before purchase. The confirmation link may be implemented through AshAuthentication, but the contract result is `User.confirmed_at != null` and `User.state == active`.
