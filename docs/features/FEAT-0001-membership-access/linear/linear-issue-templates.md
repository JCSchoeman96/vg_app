# Linear Issue Templates — FEAT-0001

Use project: `vg_app`  
Use team: `JC-Dev`

## VS-000C0

Title:

```text
VS-000C0: Hygiene and auth hardening
```

State: Todo  
Priority: High  
Blocks: VS-000C1 if repo hygiene/auth remains unresolved

Description:

```markdown
## Goal
Prepare the repo for VS-000C Memberships work by fixing hygiene/auth issues only.

## Scope
See docs/features/FEAT-0001-membership-access/slices/VS-000C0-hygiene-auth-hardening/prompt.md

## Forbidden
No Memberships resources. No Catalog. No Commerce. No Paystack. No UI.

## Branch
feature/vs-000c0-hygiene-auth-hardening

## PR Title
VS-000C0: Hygiene and auth hardening

## Required Checks
mix ash.codegen --check
mix compile --warnings-as-errors
mix test
```

## VS-000C1

Title:

```text
VS-000C1: Membership product, plan, and benefit foundation
```

Blocks: VS-000C2

Branch:

```text
feature/vs-000c1-product-plan-benefit
```

Prompt:

```text
docs/features/FEAT-0001-membership-access/slices/VS-000C1-product-plan-benefit/prompt.md
```

## VS-000C2

Title:

```text
VS-000C2: Membership lifecycle foundation
```

Blocked by: VS-000C1  
Blocks: VS-000C3

Branch:

```text
feature/vs-000c2-membership-lifecycle
```

Prompt:

```text
docs/features/FEAT-0001-membership-access/slices/VS-000C2-membership-lifecycle/prompt.md
```

## VS-000C3

Title:

```text
VS-000C3: Entitlement grants and access evaluation
```

Blocked by: VS-000C2

Branch:

```text
feature/vs-000c3-entitlement-access
```

Prompt:

```text
docs/features/FEAT-0001-membership-access/slices/VS-000C3-entitlement-access/prompt.md
```
