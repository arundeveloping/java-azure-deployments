# Auth Frontend (Vue 3)

Vue 3 + Vite client for the [auth-service](../auth-service/) API: register, login, JWT refresh, logout, profile (`/me`), and OAuth callback for Google/GitHub.

## Prerequisites

- Node.js 22+
- [auth-service](../auth-service/) running on `http://localhost:8080` (see auth-service README)

## Run locally

```bash
cd auth-frontend
npm install
npm run dev
```

Open **http://localhost:3000** (matches the backend default `OAUTH2_REDIRECT_URI`).

The dev server proxies `/api`, `/oauth2`, and `/login` to the auth service, so you do not need CORS configuration for local development.

## Production build

Set the API base URL when the app is served separately from the backend:

```bash
cp .env.example .env
# VITE_API_BASE_URL=http://localhost:8080
npm run build
npm run preview
```

Ensure `auth.cors.allowed-origins` on the auth service includes your frontend origin.

## Caching and zero-downtime deploys

**Build (handled by Vite):** `npm run build` emits content-hashed files under `dist/assets/` (for example `index-CKFrwQva.js`, `LoginView-CG8Ysu2y.js`). `dist/index.html` points at the current hashes. Code changes produce new filenames, so old and new asset files can coexist on the same origin.

**Hosting (you configure):** Avoid 404s after a deploy by combining:

| File | Cache-Control (typical) | Deploy |
|------|-------------------------|--------|
| `index.html` | `no-cache, must-revalidate` (or short `max-age`) | Overwrite on each release |
| `/assets/*` (hashed `.js` / `.css`) | `public, max-age=31536000, immutable` | Upload new files; **do not delete** previous hashes until retention expires |

Deploy flow: upload new hashed JS/CSS → upload new `index.html` → keep V1 + V2 + … assets on disk/blob until a cleanup job removes hashes no longer referenced by any served `index.html` (often 7/14/30 days).

**Not hashed:** files from `public/` (for example `favicon.svg`) keep fixed URLs. Only change them when you accept cache staleness, or version the path yourself.

For **Azure Static Web Apps**, cache headers and SPA routing are in [`public/staticwebapp.config.json`](public/staticwebapp.config.json). Deploy with [`.github/workflows/cd-static-web-app.yml`](../.github/workflows/cd-static-web-app.yml) — see [docs/AZURE-STATIC-WEB-APPS.md](docs/AZURE-STATIC-WEB-APPS.md).

## Features

| Route | Purpose |
|-------|---------|
| `/login` | Email/password sign-in + social buttons |
| `/register` | New user registration |
| `/auth/callback` | OAuth redirect handler (tokens in query string) |
| `/dashboard` | Protected profile view from `GET /api/v1/auth/me` |

Tokens are stored in `localStorage` and refreshed automatically before expiry.
