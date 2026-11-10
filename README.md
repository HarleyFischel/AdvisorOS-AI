# AdvisorOS AI

AdvisorOS AI is an interview-ready financial advisor CRM foundation: a modular Rails JSON API, a responsive React/TypeScript workspace, PostgreSQL tenancy boundaries, secure server-managed sessions, audit events, and a deliberately unimplemented AI assistant surface for Mission 002.

## Stack

- Ruby 3.3.6, Rails 8.1.4.1, PostgreSQL 16
- React 19, TypeScript 5.7.3, Vite 6.4.6, TanStack Query 5
- Dark and light themes with System as the default preference
- RSpec, Vitest, Playwright, RuboCop, Brakeman
- Docker Compose for local API, web, and database services

## Quick start

Prerequisites: Docker Desktop (Linux, macOS, or GitHub Codespaces) and Git.

```sh
cp .env.example .env
make setup
make up
open http://localhost:5173 # macOS; use a browser on Linux/Codespaces
```

`make setup` builds the images, prepares the database, and loads deterministic synthetic demo data. PostgreSQL is exposed only to the Compose network. The web UI is available at `http://localhost:5173`; choose System, Light, or Dark under Settings. The Vite development server can also be placed behind a tunnel when its hostname is added to `apps/web/vite.config.ts`.

Demo accounts all use `DemoPass!2026`:

- `admin@northstar.demo` — full organization administration
- `advisor@northstar.demo` — CRM management
- `viewer@northstar.demo` — read-only access

These accounts and all data are synthetic. Never use them in production.

## API overview

The Rails API is namespaced under `/api/v1`. It provides session/CSRF endpoints, current user, dashboard aggregations, household CRUD, client CRUD, opportunity CRUD and stage changes, and client activities. Responses use `{ data, meta }` for successful collections and `{ error: { code, message, details } }` for safe failures. Pagination accepts `page` and `per_page` (capped at 100); clients accept `q`, `status`, `sort`, and `direction`.

## Architecture and security

The application is a modular monolith with explicit tenant scoping in every controller query and model-level association checks. Session cookies are signed, HttpOnly, SameSite=Lax, and secure in production. State-changing requests require a Rails CSRF token. Roles are enforced server-side; viewers cannot mutate CRM records. Important mutations create immutable-by-input audit events. See [system architecture](docs/architecture/system.md) and the ADRs in `docs/decisions/`.

Safe deletion is intentionally conservative: households with clients and clients with activities or opportunities cannot be deleted; opportunities can be deleted only by authorized roles. This avoids silently destroying relationship history.

## Testing and commands

```sh
make test       # RSpec and Vitest
make lint       # RuboCop, Brakeman, TypeScript, ESLint
docker compose run --rm web npm run e2e
```

The Playwright smoke suite expects the Compose services and seeded demo data to be running. It covers admin client creation/editing/activity logging/safe deletion, household creation/editing/deletion, opportunity creation/editing/stage changes/deletion, viewer restrictions, theme switching, and logout. CI runs the API and frontend validation checks on pull requests; the local Compose-backed browser suite is the end-to-end validation path.

## Screenshots

Run the app, sign in with the admin demo account, and capture the Overview, Clients, Pipeline, and AI Assistant pages. Screenshots are intentionally generated from synthetic data rather than committed as product claims.

## Known limitations and roadmap

Mission 001 does not connect to a paid LLM, brokerage, document store, or AWS account. Activity deletion is intentionally not exposed, and clients/households with important related records are protected from deletion. Login rate limiting uses a PostgreSQL-backed shared counter for this local modular-monolith baseline; a production deployment should add monitoring, cleanup/retention, and consider an edge or Redis limiter at higher scale. The demo Vite server is not a production deployment target.
