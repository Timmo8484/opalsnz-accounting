# Architecture Decisions

Reference architecture: `C:\src\opalsnz` (ASP.NET Core 8 API + Flutter Web + MySQL + Docker, deployed
to Proxmox/Windows Server). This app reuses the same core stack and layering conventions, simplified
for a single-user internal tool.

## Reused from opalsnz

| Aspect | opalsnz | This app |
|---|---|---|
| Backend | ASP.NET Core 8 API, layered projects (Api/Db/Model/Service) | Same layering: `Opalsnz.Accounting.Api/.Db/.Model/.Service` |
| ORM / DB | EF Core against MySQL 8 | Same — EF Core + MySQL (Pomelo provider), new schema on the existing MySQL server |
| Frontend | Flutter Web, BLoC state management, `lib/bloc/{domain}` pattern | Same pattern, one BLoC per domain (income, home office expense, business purchase, asset, report, auth) |
| Deployment | Docker Compose per environment, nginx, Proxmox/Windows Server | Same infra reused, new Compose services |
| Logging | Serilog to console | Reused as-is |

## Simplified / dropped from opalsnz

| Aspect | opalsnz | Why dropped here |
|---|---|---|
| Auth provider | Firebase Auth (JWT bearer validated against Firebase) | Single user, no public sign-up — a self-issued JWT (password/PIN login, symmetric signing key from config/env) avoids an external dependency |
| Payments | Stripe | No payment processing needed — this is a record-keeping tool, not a storefront |
| Media | YouTube API, image/video upload handling | Not relevant to accounting records |
| Rate limiting | Address autocomplete rate limiter | No public-facing endpoints that need burst protection |
| Multi-region deploy | Separate pi/server1/server2 production Compose files | Single deployment target is enough for a personal tool |
| Mapper project | Separate `Opalsnz.Mapper` project | Folded into `.Service` — entity count is small enough that a dedicated mapping project adds ceremony without benefit |

## New concerns specific to this app

- **Sensitive financial data** — recommend internal-only/VPN access rather than a public subdomain
  (decide in the infrastructure phase).
- **Single-user auth** — no registration flow, no roles/claims beyond "is authenticated"; credential
  managed via config/DB rather than a user-management system.
- **Tax-domain logic** lives in `.Service` (GST calculator, home-office claim calculator, depreciation
  calculator) so it's unit-testable independent of the API/DB.

## Related documents

- [plan.md](../plan.md)
- [tax/nz-sole-trader-tax-overview.md](./tax/nz-sole-trader-tax-overview.md)
