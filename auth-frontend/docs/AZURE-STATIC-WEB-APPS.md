# Deploy auth-frontend to Azure Static Web Apps

This app is a Vue 3 SPA with Vite **content-hashed** assets under `/assets/`. `public/staticwebapp.config.json` is copied into `dist/` on build and configures caching and client-side routes.

## Cache behavior on SWA

| Request | Behavior |
|---------|----------|
| `/assets/*.{js,css}` | `Cache-Control: public, max-age=31536000, immutable` |
| `/index.html`, `/`, `/*.html` | `no-cache, no-store, must-revalidate` |
| SPA paths (`/login`, `/dashboard`, …) | `navigationFallback` → `index.html` with `globalHeaders` `no-cache, must-revalidate` |

SWA applies **route header rules to real files only**, not to `navigationFallback` responses. That is why `globalHeaders` defaults to short-lived HTML-style caching while `/assets/*` overrides with long-lived immutable cache.

**Important:** Each SWA deployment uploads the current `dist/` output. Unlike blob storage with manual retention, **previous hashed files are not kept** after a deploy. Fresh `index.html` (no-cache) is what prevents most post-deploy 404s; users on a very old tab without refresh may still request removed hashes until they reload.

## One-time setup (Azure Portal)

1. **Create Static Web App**
   - Resource group: same as auth-service (or new)
   - Plan: Free or Standard
   - Deployment: **GitHub** → select this repo and branch `main`
   - Build presets: **Custom**
   - App location: `auth-frontend`
   - Output location: `dist`
   - App build command: `npm ci && npm run build`

2. **GitHub secret**  
   After creation, Azure adds `AZURE_STATIC_WEB_APPS_API_TOKEN` (or similar) to the repo. If you use this repo’s workflow [`.github/workflows/cd-static-web-app.yml`](../../.github/workflows/cd-static-web-app.yml), copy the deployment token into secret name **`AZURE_STATIC_WEB_APPS_API_TOKEN`**.

3. **GitHub variable**  
   Set **`VITE_API_BASE_URL`** to your auth-service public URL (no trailing slash), e.g.  
   `https://authdev-app.happygrass-12345678.eastus.azurecontainerapps.io`  
   Used at build time so the browser calls the API directly (CORS required).

4. **Auth service CORS**  
   Add the SWA URL to `CORS_ALLOWED_ORIGINS` / `auth.cors.allowed-origins`, e.g.  
   `https://<your-app>.azurestaticapps.net`

5. **OAuth redirect (optional)**  
   Set `OAUTH2_REDIRECT_URI` on auth-service to:  
   `https://<your-app>.azurestaticapps.net/auth/callback`

## CI/CD

Pushes to `main` that touch `auth-frontend/**` run **CD - Auth Frontend (Azure Static Web Apps)**. Pull requests get a **preview URL**; closing the PR tears down the preview environment.

## Local verify before deploy

```bash
cd auth-frontend
npm ci
VITE_API_BASE_URL=https://your-auth-service.example npm run build
```

Confirm `dist/staticwebapp.config.json` exists and `dist/index.html` references hashed files under `/assets/`.

## Custom domain (optional)

Static Web Apps → **Custom domains** → add domain → update CORS and `OAUTH2_REDIRECT_URI` to match.
