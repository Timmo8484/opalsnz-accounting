# Infrastructure & Deployment

Deploys to the same infrastructure as opalsnz (Proxmox/Windows Server, Docker Compose, nginx), reusing
its patterns but simplified for a single-user internal tool — see
[../docs/architecture-decisions.md](../docs/architecture-decisions.md).

## Recommended access path

**Internal-only / VPN**, not a public subdomain — this app holds your personal financial records.
Don't put it behind Cloudflare or expose it on the public internet the way opalsnz's storefront is.
Reasonable options, in order of simplicity:

1. Bind the frontend port to the LAN only (or your existing VPN interface) rather than `0.0.0.0`.
2. Put it behind the same reverse proxy/VPN you'd use for other internal-only services.
3. If you do want external access, put it behind your VPN (e.g. WireGuard/Tailscale) rather than a
   public DNS name.

## Images

- `backend/Dockerfile` — multi-stage build, ASP.NET Core 10 published app, runs as a non-root user,
  `/health` endpoint (anonymous, despite the app's secure-by-default auth policy — required for the
  container healthcheck and any orchestrator probes to work).
- `frontend/opalsnz_accounting_app/Dockerfile` — multi-stage build, `flutter build web --release` served
  by nginx. **`API_BASE_URL` is baked in at image build time** (`--build-arg API_BASE_URL=...`), so it
  must already point at wherever the backend will be reachable from your browser before you build the
  frontend image.

Both Dockerfiles were built and smoke-tested locally against the dev DB during development (see
plan.md) — the health check fix above was caught this way.

## Running

```powershell
# One-time: shared network both containers join
docker network create opalsnz-accounting-network

# Backend
cd backend
docker build -t opalsnz-accounting-backend:latest .
# Set DATABASE_HOST/PORT/NAME/USERNAME/PASSWORD, JWT_SIGNING_KEY, SINGLE_USER_USERNAME,
# SINGLE_USER_PASSWORD_HASH, FRONTEND_ORIGIN as environment variables or a .env file, then:
docker compose -f docker-compose.backend.production.yml up -d

# Frontend (build-arg must point at the backend's externally-reachable URL)
cd ../frontend/opalsnz_accounting_app
docker build --build-arg API_BASE_URL=https://accounting.internal.example -t opalsnz-accounting-frontend:latest .
cd ..
docker compose -f docker-compose.frontend.production.yml up -d
```

## Secrets

Never commit real values. Generate your own:
- `JWT_SIGNING_KEY` — random 32+ byte value, e.g. `[Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))` in PowerShell.
- `SINGLE_USER_PASSWORD_HASH` — PBKDF2 hash in the app's format (see `Opalsnz.Accounting.Service.Auth.PasswordHasher`); don't reuse the dev password hash from `appsettings.Development.json`.
- Database credentials — either a new schema/user on the existing opalsnz MySQL server, or a dedicated
  container (see `db/docker-compose.db.dev.yml` as a starting point for a production compose file, which
  hasn't been created yet — see Further considerations in plan.md).

## Database

This repo only has a **dev** MySQL Compose file (`db/docker-compose.db.dev.yml`) so far. For production,
either:
- Add a schema to the existing opalsnz MySQL server (simplest, no new DB instance to manage), or
- Stand up a dedicated MySQL container using `db/docker-compose.db.dev.yml` as a starting point (change
  the root/user passwords, remove the dev port mapping, add it to `opalsnz-accounting-network`).

Either way, apply `db/opalsnz_accounting/sql/*.sql` via Flyway before starting the backend for the
first time (see backend/README.md's scaffold section for the Flyway container pattern used in dev).

## Backups

Not yet set up — mirror opalsnz's `infrastructure/scripts/backup*.ps1`/`.sh` pattern once the production
database location is decided.
