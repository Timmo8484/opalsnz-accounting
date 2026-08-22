# Plan: OpalsNZ Accounting App

Personal, single-user record-keeping app for a NZ sole trader with two income streams
(software development contracting, opal gemstone cutting/selling) that are combined
as one business income for tax purposes.

Architecture is modelled on `C:\src\opalsnz` (ASP.NET Core API + Flutter Web + MySQL + Docker),
simplified for a single-user internal tool.

## Decisions

| Topic | Decision |
|---|---|
| Tech stack | Same core stack as opalsnz (ASP.NET Core 8 API, Flutter Web, MySQL, Docker), simplified — drop Firebase/Stripe/YouTube/rate-limiting/multi-region concerns |
| Auth | Single-user password/PIN login, self-issued JWT (no Firebase) |
| Hosting | Same infra as opalsnz (Proxmox/Windows Server), reuse existing MySQL server with a new schema |
| GST | Registered, bi-monthly (two-monthly) filing |
| Accounting basis | Cash basis (income/expenses recorded when money moves) |
| Balance date | 31 March (standard NZ tax year) |
| Depreciation | Track an asset register; app auto-calculates yearly depreciation (diminishing value or straight line) from a user-entered IRD rate |
| Home office % | Fixed, user-editable percentage per expense category (not floor-area calculated) |
| Opal stock | **Trading stock register** (periodic/annual method) — replaces the earlier "simple expense entries only" decision. One `TradingStockYear` record per tax year holds an opening value (first year = the confirmed pre-business value, later years = prior year's closing value), a closing value entered at year end, and the valuation method; deductible cost for the year = opening + purchases − closing. Purchases are still logged as normal `BusinessPurchase` entries (flagged as trading stock), just no per-item/per-stone COGS matching against sales. See [docs/tax/trading-stock-and-startup-assets.md](docs/tax/trading-stock-and-startup-assets.md). |
| Bank data | Manual entry now; schema should not block a future CSV import, but it isn't built yet |
| Mapper layer | Folded into `.Service` project rather than a separate `.Mapper` project (small entity count doesn't justify it) |
| Reports | Category totals / GST period summary / depreciation schedule for handing to an accountant; CSV export in scope, PDF export is a stretch goal only |
| ACC levies | Not a separate module — ACC levy payments are recorded as a normal business expense entry (deductible), reducing net profit alongside income tax; no dedicated ACC entity |
| .NET version | net10.0 (current LTS, matches installed SDKs) rather than opalsnz's net8.0 — EF Core packages pinned to 9.0.11 (and Pomelo.EntityFrameworkCore.MySql 9.0.0) since that's the latest Pomelo release, avoiding an EF Core 10/Pomelo 9 version mismatch |
| Schema management | Db-first, matching opalsnz exactly: Flyway SQL migrations (`db/opalsnz_accounting/sql`) own the schema; EF Core models are regenerated via `scaffold-db.ps1` (`dotnet ef dbcontext scaffold`), not EF Core code-first migrations |

## Domain facts encoded (see `docs/tax/`)

- GST rate 15%; GST content of a GST-inclusive amount = amount × 3/23.
- GST only claimable on costs that actually include GST (power/internet/insurance — yes; mortgage interest — no, financial services are GST-exempt).
- Home office costs apportioned by a fixed % per category the user sets and can edit later (e.g. 25% mortgage interest, 50% power/internet).
- Capital assets costing more than $1,000 (excl. GST) must be depreciated using IRD rates (IR265 guide); assets costing $1,000 or less can be expensed immediately in the year of purchase (low-value asset threshold, in effect since 17 Mar 2021).
- Diminishing value (DV): depreciation for the year = opening book (adjusted tax) value × rate. Straight line (SL): depreciation = original cost × rate. Both apportioned for part-year ownership.
- GST filing periods here are two-monthly, aligned to standard IRD periods, returns due on the 28th of the month following period end.
- ACC levies are calculated from the same net profit figure as income tax (liable earnings × classification-unit rate), invoiced separately and in arrears by ACC, and are themselves a deductible business expense when paid.
- Trading stock (raw opal held for resale) is deducted via opening/closing stock values, not as a lump-sum expense; the low-value concession (skip formal valuation) only applies below $1.3m sales and <$10,000 estimated closing stock — doesn't apply here given ~$50k of opal rough. See [docs/tax/trading-stock-and-startup-assets.md](docs/tax/trading-stock-and-startup-assets.md).

## Phases

Work proceeds in phases below. **Pause after each phase for review before starting the next.**

### Phase 1 — Context docs & cheatsheets ✅ (this phase)
- `plan.md` (this file)
- `docs/tax/nz-sole-trader-tax-overview.md`
- `docs/tax/gst-quick-reference.md`
- `docs/tax/depreciation-cheatsheet.md`
- `docs/tax/home-office-expenses.md`
- `docs/architecture-decisions.md`

### Phase 2 — Repo & backend scaffold ✅
Mirror opalsnz top-level layout (`backend/`, `db/`; `frontend/` and `infrastructure/` added in their
respective phases). Backend solution `Backend.sln` with `Opalsnz.Accounting.Api/.Db/.Model/.Service`
projects (net10.0), self-issued JWT auth (single user, PBKDF2 password hash, credential from
config/env), Serilog, CORS, health check, EF Core + Pomelo MySQL wiring. Local dev MySQL + Flyway via
`db/docker-compose.db.dev.yml`.

### Phase 3 — Data model & migrations ✅
Entities: `IncomeEntry`, `ExpenseCategory`, `HomeOfficeExpenseEntry`, `BusinessPurchase` (with an
`IsTradingStockPurchase` flag for opal rough), `Asset`, `AssetDepreciationYear`, `TradingStockYear`
(opening/closing stock value per tax year — see [docs/tax/trading-stock-and-startup-assets.md](docs/tax/trading-stock-and-startup-assets.md)),
`HistoricalStockPurchase` (record-keeping only: logs the ~3 years of pre-business bank-statement
purchases as evidence, not part of the deductible-cost calculation). Schema defined as Flyway SQL
migrations against the local/dev MySQL (`db/opalsnz_accounting/sql/V1__create_core_schema.sql`, plus
`V2__seed_expense_categories.sql` seeding the example home-office categories/% from
[docs/tax/home-office-expenses.md](docs/tax/home-office-expenses.md)), then `Opalsnz.Accounting.Db`'s
`AccountingContext`/models regenerated via `scaffold-db.ps1` (db-first, not EF Core code-first
migrations) — verified against the local dev MySQL container, solution builds clean.

### Phase 4 — API endpoints & calculator unit tests
CRUD controllers for each entity + a Reports controller: income summary by stream, home-office
claimable summary, GST period summary (output GST − input GST), depreciation schedule, CSV export.
A new `Opalsnz.Accounting.Tests` project is added here (xUnit), with unit tests written alongside each
calculator as it's built: GST content calc, home-office claimable calc, DV/SL depreciation calc
(incl. part-year apportionment), low-value asset (≤$1,000) immediate-expense logic, and the trading
stock deductible-cost calc (opening + purchases − closing).

### Phase 5 — Frontend (Flutter Web)
Scaffold app with `lib/bloc/{income,homeOfficeExpense,businessPurchase,asset,report,auth}`, `lib/pages`,
`lib/services` (API client). Pages: Login, Dashboard, Income List, Home Office Expenses, Business
Purchases, Assets & Depreciation, Reports, Settings.

### Phase 6 — Infrastructure & deployment
Docker Compose (dev + production) reusing opalsnz's nginx/Docker patterns, deployed to existing
Proxmox/Windows Server infra. Decide access path (internal-only/VPN recommended given sensitive
financial data vs a public subdomain).

### Phase 7 — Final verification
Manual pass through the running app: one income entry per stream, one home-office expense per
category, one capital asset purchase >$1,000 and one ≤$1,000 (confirm immediate-expense flag), generate
a GST-period report and an annual summary, export CSV. Confirm the Phase 4 unit test suite still passes
end-to-end against the finished app.

## Reference files (opalsnz patterns being reused)

- `C:\src\opalsnz\backend\Opalsnz.Api\Program.cs` — JWT/Serilog/CORS setup pattern to simplify
- `C:\src\opalsnz\backend\Opalsnz.Db\OpalsnzContext.cs` — EF Core DbContext pattern
- `C:\src\opalsnz\backend\Opalsnz.Service\*Service.cs` — service-layer pattern
- `C:\src\opalsnz\frontend\opalsnz_app\lib\bloc\` and `bloc-architecture.md` — BLoC pattern per domain
- `C:\src\opalsnz\db\docker-compose.db.dev.yml` — DB compose pattern to adapt

## Open questions (revisit later, not blocking)

1. Deployment access path — internal-only/VPN vs public subdomain.
2. PDF export for accountant handoff — stretch goal, not committed.
3. Trading stock register is now designed (see Phase 3 and [docs/tax/trading-stock-and-startup-assets.md](docs/tax/trading-stock-and-startup-assets.md)), but the **opening value figure and valuation method** (cost vs market value) for the ~$50k of pre-business opal rough still needs your accountant's confirmation before that first `TradingStockYear` record is entered — not blocking the build, just don't enter a real opening value until confirmed.
