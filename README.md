# OpalsNZ Accounting

Personal sole-trader record-keeping app for NZ income tax, GST, and ACC obligations, covering two
combined income streams: software development contracting and opal gemstone cutting/selling.

Architected the same way as [opalsnz](https://opals.co.nz)'s website, simplified for a single-user
internal tool — see [docs/architecture-decisions.md](docs/architecture-decisions.md) for what's reused
vs dropped.

## Project structure

- **Backend** — ASP.NET Core 10 API (`/backend`)
- **Frontend** — Flutter web application (`/frontend`)
- **Database** — MySQL configuration (`/db`)
- **Infrastructure** — Deployment scripts and configuration (`/infrastructure`)
- **docs** — Tax cheatsheets and architecture notes (`/docs`)

See [plan.md](plan.md) for the full build plan, decisions, and phase breakdown.

## Technology stack

- **Backend**: ASP.NET Core 10, Entity Framework Core (Pomelo MySQL provider)
- **Database**: MySQL 8, schema managed with Flyway SQL migrations
- **Frontend**: Flutter web (BLoC state management)
- **Auth**: Single-user, self-issued JWT (no third-party auth provider)

## Development

See [backend/README.md](backend/README.md) for backend setup instructions and
[frontend/opalsnz_accounting_app/README.md](frontend/opalsnz_accounting_app/README.md) for the frontend.
