# Frontend

Flutter web app, architected the same way as opalsnz's frontend (BLoC state management, one BLoC per
domain), but as a single app package rather than opalsnz's 3-package melos monorepo — see
[../../docs/architecture-decisions.md](../../docs/architecture-decisions.md).

## Prerequisites

- Flutter 3.32.8 / Dart 3.8.1 (same version as opalsnz)
- The backend API running locally (see [../../backend/README.md](../../backend/README.md))

## Running locally

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5064
```

`API_BASE_URL` defaults to `http://localhost:5064` if omitted. The backend's
`Cors:AllowedOrigins` (in `appsettings.Development.json`) must include whatever origin/port the
frontend is served from — `http://localhost:8081` is pre-configured for
`flutter run -d web-server --web-port 8081`.

Default dev login: username `owner`, password `ChangeMe123!` (see backend README).

## Structure

- `lib/models` — Dart classes mirroring the API's DTOs
- `lib/services` — `ApiClient` (adds the bearer token) plus one service per domain
- `lib/bloc/{domain}` — event/state/bloc per domain, matching opalsnz's `bloc-architecture.md` pattern
- `lib/pages` — one page per feature area, `AppShell` provides the side navigation

## Known gaps

- No edit forms yet (add/delete only) — the API supports `PUT` on every entity already
- No CSV/PDF export UI
