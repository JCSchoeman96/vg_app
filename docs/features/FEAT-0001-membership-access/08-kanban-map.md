# 08 — Kanban Map

## Board flow

```text
Backlog
|> Ready for planning
|> Feature grilled
|> Backend grilled
|> Feature pack locked
|> Ready for coding
|> In coding
|> PR opened
|> PR review
|> Changes requested
|> Ready to merge
|> Merged
|> Ledger updated
|> Done
```

## Issues

### VS-000C0 — Hygiene/auth hardening

Depends on: none  
Blocks: C1 if repo hygiene remains broken  
Parallel: can run before or with docs-only workflow work

### VS-000C1 — Product, plan, benefit foundation

Depends on: C0 if required  
Blocks: C2  
Parallel: none

### VS-000C2 — Membership lifecycle

Depends on: C1  
Blocks: C3

### VS-000C3 — Entitlement grants/access evaluation

Depends on: C2  
Blocks: VS-000D/Catalog and VS-000E/Commerce

## Linear issue template

Each Linear issue SHALL include:

- goal
- scope
- forbidden scope
- dependencies
- branch name
- PR title
- relevant docs path
- coding-agent prompt path
- required checks
