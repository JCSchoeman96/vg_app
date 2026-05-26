# 07. Tenancy and Ownership Map

v0.2.7 SHALL be global/single-tenant for the membership commerce foundation until tenancy is explicitly introduced by a future contract.

## Ownership

| Resource | Owner domain | Tenant scope |
|---|---|---|
| User | Accounts | global |
| UserProfile | Accounts | global |
| ConsentRecord | Accounts | global |
| AccountRole | Accounts | global |
| MembershipProduct | Memberships | global |
| MembershipPlan | Memberships | global |
| Membership | Memberships | global |
| BenefitRule | Memberships | global |
| EntitlementGrant | Memberships | global |
| Offer | Catalog | global |
| Price | Catalog | global |
| Order | Commerce | global |
| OrderItem | Commerce | global |
| Payment | Commerce | global |
| PaymentEvent | Commerce | global |

No resource SHALL silently introduce tenant_id in v0.2.7.
