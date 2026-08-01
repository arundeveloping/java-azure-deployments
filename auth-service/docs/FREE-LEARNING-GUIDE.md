# Free Learning Path for Auth Service + CI/CD + Azure

This guide is for **learning only** — start free, add paid Azure services later when you're comfortable.

---

## Recommended learning phases

```
Phase 1 (FREE)     Local Docker + Postman
       │
Phase 2 (FREE)     GitHub Actions CI (build & test)
       │
Phase 3 (FREE*)    Deploy to cloud with free credits / free tiers
       │
Phase 4 (PAID)     Full Azure production stack (Bicep in azure/)
```

\* Phase 3 can be $0 with trial credits or external free services.

---

## Phase 1: Local only — $0

**Best place to start.** You already have everything.

```powershell
cd auth-service
docker compose up postgres redis -d
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

| Tool | Cost | What you learn |
|------|------|----------------|
| Docker Compose | Free | Containers, PostgreSQL, Redis |
| Maven | Free | Java builds, tests |
| Postman | Free | REST APIs, JWT flows |
| Swagger UI | Free | API documentation |

**Practice:**
1. Register → Login → `/me` → Refresh → Logout
2. Read the code flow (Controller → Service → Security)
3. Break things on purpose (wrong password, expired token)

---

## Phase 2: CI pipeline only — $0

Use **GitHub Actions** free tier:
- **Public repos:** unlimited minutes
- **Private repos:** 2,000 minutes/month free

### What to use

Only enable: `.github/workflows/ci.yml`

This runs on every push/PR:
- `mvn test`
- Build JAR
- Validate Docker image (no push, no Azure)

### Setup (5 minutes)

1. Push code to GitHub
2. Go to **Actions** tab — CI runs automatically
3. No Azure account needed

**What you learn:** automated testing, build pipelines, failing fast on broken code.

---

## Phase 3: Cloud deploy on a budget — $0 to ~$5/month

### Option A: Azure free credits (best for learning Azure)

| Program | Credit |
|---------|--------|
| [Azure free account](https://azure.microsoft.com/free/) | $200 for 30 days |
| [Azure for Students](https://azure.microsoft.com/free/students/) | $100 (no credit card for students) |

Use credits to try the full Bicep deployment in `azure/main.bicep`, then **delete the resource group** when done:

```powershell
az group delete --name rg-auth-service-dev --yes --no-wait
```

> Always run `az group delete` after learning sessions to avoid charges.

---

### Option B: Minimal Azure (~lowest ongoing cost)

Skip expensive managed DB/Redis initially. Use **free external services**:

| Service | Free tier | Use for |
|---------|-----------|---------|
| [Neon](https://neon.tech) | Free PostgreSQL | Database |
| [Upstash](https://upstash.com) | Free Redis | Token blacklist |
| [GitHub Container Registry](https://docs.github.com/packages) | Free (public repos) | Docker images |
| Azure Container Apps | Pay per use, can be pennies | Run the app |

**Monthly cost:** often **$0–5** if you scale down and use free DB/Redis.

---

### Option C: Stay 100% free — no Azure hosting

| Platform | Free tier | Notes |
|----------|-----------|-------|
| [Render](https://render.com) | Free web service | Sleeps after inactivity |
| [Fly.io](https://fly.io) | Free allowance | Good for containers |
| [Railway](https://railway.app) | $5 trial credit | Easy Docker deploy |

Connect with GitHub Actions CD — same CI/CD concepts, different host.

---

## What to skip while learning (save money)

| Skip for now | Why | Use instead |
|--------------|-----|-------------|
| Azure Database for PostgreSQL | ~$12+/month | Docker Postgres locally or Neon free |
| Azure Cache for Redis | ~$16/month | Docker Redis locally or Upstash free |
| Azure Container Registry | ~$5/month | GitHub Container Registry (free) |
| Key Vault | Small cost | Env vars in Container Apps for dev |
| Multi-environment (dev/staging/prod) | 3x cost | One `dev` environment only |

---

## Free CI/CD comparison

| Tool | Free tier | Best for |
|------|-----------|----------|
| **GitHub Actions** | 2000 min/mo (private) | This project — already configured |
| **Azure DevOps** | 1800 min/mo, 1 free parallel job | If you prefer Microsoft ecosystem |
| **GitLab CI** | 400 min/mo | All-in-one repo + CI |

**Recommendation:** GitHub Actions + public repo = **unlimited free CI**.

---

## Suggested 4-week learning plan

### Week 1 — Local
- [ ] Run app with Docker Compose
- [ ] Test all APIs with Postman collection
- [ ] Trace login flow in code (Controller → AuthService → JwtService)

### Week 2 — CI
- [ ] Push to GitHub, watch CI pipeline pass/fail
- [ ] Break a test on purpose, fix it, see CI catch it
- [ ] Read `.github/workflows/ci.yml`

### Week 3 — Cloud basics
- [ ] Create Azure free account
- [ ] Deploy with `docker compose` on a free VM OR use Azure $200 credit
- [ ] Hit `/actuator/health` on a public URL

### Week 4 — CD
- [ ] Set up GitHub Actions CD (or manual `docker push` + `az containerapp update`)
- [ ] Deploy one change end-to-end: code → CI → image → running app
- [ ] Delete Azure resources when done

---

## Free learning resources

| Topic | Resource |
|-------|----------|
| Spring Security | [spring.io/guides](https://spring.io/guides) |
| OAuth2 / JWT | [OAuth.net](https://oauth.net/2/) |
| Docker | [Docker getting started](https://docs.docker.com/get-started/) |
| GitHub Actions | [GitHub Actions docs](https://docs.github.com/actions) |
| Azure basics | [Microsoft Learn — AZ-900](https://learn.microsoft.com/credentials/certifications/resources/study-guides/az-900) (free learning paths) |
| Bicep | [Microsoft Learn — Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/) |

---

## My recommendation for you right now

```
1. Phase 1 (this week)  → docker compose + Postman     [$0]
2. Phase 2 (next week)  → GitHub Actions CI only       [$0]
3. Phase 3 (when ready) → Azure free $200 credit       [$0 for 30 days]
4. Delete resources     → az group delete               [avoid charges]
```

Don't deploy the full `azure/main.bicep` stack until you understand local dev and CI. The full stack is for when you're ready to learn production Azure — not day one.

---

## Quick commands cheat sheet

```powershell
# Local dev (free)
docker compose up postgres redis -d
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Run tests (free)
mvn test

# Stop local infra (free)
docker compose down

# Delete ALL Azure resources (stop billing)
az group delete --name rg-auth-service-dev --yes
```
