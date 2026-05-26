# VS-001B — Login, Password Reset, and Staff Role Foundation

## Status
READY_FOR_REVIEW_CLEAN

## Resources involved
- `User`
- `AccountRole`

## Actions involved
- `Accounts.login_user`
- `Accounts.request_password_reset`
- `Accounts.reset_password`
- `Accounts.bootstrap_staff_admin`
- `Accounts.assign_role`

## Blocking decisions
- none

## Required tests
- `login_requires_valid_credentials`
- `password_reset_token_can_reset_password`
- `staff_admin_role_required_for_admin_actions`
- `system_is_not_stored_as_user_role`

## Slice law
This slice makes actors real. `staff_admin` SHALL be represented through AccountRole. `system` SHALL remain an internal context and not a login role.
