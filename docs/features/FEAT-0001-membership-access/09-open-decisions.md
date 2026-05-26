# 09 — Open Decisions

## OD-001: Exact AshPostgres partial unique index shape

Decision needed during VS-000C2 implementation:

- Use Ash identity/constraints if it supports partial unique index cleanly.
- Otherwise add explicit migration index with `where: "state = 'active'"`.

Requirement remains locked: one active membership per user/product must be enforced at DB level if feasible.

## OD-002: Calendar duration helper location

Decision needed during VS-000C2 implementation:

- Put helper in `VgApp.Memberships.Duration`
- Or use a private helper in resource/action module if small

Requirement remains locked: monthly/yearly interval/count logic must be deterministic and tested.

## OD-003: AccountRole read policy timing

Preferred: harden in VS-000C0 before C1.

If not done in C0, C1 should not expand role-dependent behaviour beyond setup actions.
