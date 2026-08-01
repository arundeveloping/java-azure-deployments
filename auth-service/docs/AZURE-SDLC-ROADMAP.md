# Azure SDLC Master Roadmap — auth-service

Complete learning path to master Azure cloud SDLC for a Java microservice and crack interviews.

**Project:** OAuth2 `auth-service` (Spring Boot 3, JWT, PostgreSQL, Redis)  
**Goal:** Understand every layer from code commit → production → monitoring  
**Timeline:** 12 weeks (adjust pace as needed)

---

## The big picture — SDLC on Azure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOFTWARE DEVELOPMENT LIFECYCLE                        │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬─────────┤
│   PLAN   │   CODE   │  BUILD   │   TEST   │  RELEASE │  DEPLOY  │ OPERATE │
├──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
│ Azure    │ Git /    │ CI       │ Unit +   │ CD       │ Spring   │ Monitor │
│ Boards   │ Azure    │ Pipeline │ Integr.  │ Pipeline │ Apps /   │ App     │
│ (opt.)   │ Repos    │ GitHub   │ Tests    │          │ Container│ Insights│
│          │          │ Actions  │          │          │ Apps     │         │
├──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────┤
│  CROSS-CUTTING: Key Vault │ API Management │ App Gateway │ Service Bus     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Target production architecture (what you're learning toward)

```
                    Internet
                        │
                        ▼
            ┌───────────────────────┐
            │ Application Gateway   │  ← WAF, SSL termination, routing
            │ (Layer 7 load balancer)│
            └───────────┬───────────┘
                        │
            ┌───────────▼───────────┐
            │   API Management      │  ← Rate limit, API keys, versioning
            │   (APIM)              │
            └───────────┬───────────┘
                        │
            ┌───────────▼───────────┐
            │  Azure Spring Apps    │  ← Run auth-service (or Container Apps)
            │  auth-service         │
            └─┬─────────┬─────────┬─┘
              │         │         │
              ▼         ▼         ▼
        ┌─────────┐ ┌──────┐ ┌──────────────┐
        │Key Vault│ │ PG / │ │ Redis Cache  │
        │ secrets │ │ Neon │ │ / Upstash    │
        └─────────┘ └──────┘ └──────────────┘
              │
              ▼
        ┌──────────────┐     ┌─────────────────┐
        │ Service Bus  │────▶│ Other services  │
        │ / Event Hubs │     │ (user-service)  │
        └──────────────┘     └─────────────────┘
              │
              ▼
        ┌──────────────────────┐
        │ Application Insights │  ← Logs, metrics, traces, alerts
        │ + Azure Monitor      │
        └──────────────────────┘

        ┌──────────────────────┐
        │ CI/CD (GitHub/Azure  │  ← Build → Test → Deploy
        │ DevOps Pipelines)    │
        └──────────────────────┘
```

---

## Learning phases overview

| Phase | Weeks | Focus | Interview level |
|-------|-------|-------|-----------------|
| 0 | Done | Local dev, OAuth, Docker | Junior |
| 1 | 1–2 | CI/CD fundamentals | Junior–Mid |
| 2 | 3–4 | Deploy + Key Vault + Monitor | Mid |
| 3 | 5–6 | API Management | Mid |
| 4 | 7–8 | Messaging (Service Bus / Event Hubs) | Mid–Senior |
| 5 | 9–10 | Application Gateway | Mid–Senior |
| 6 | 11–12 | Spring Apps + full integration | Senior-ready |

---

# PHASE 1 — CI/CD (Weeks 1–2)

## What it is
Automate: every code change → build → test → (optionally) deploy.

## SDLC role
**BUILD + TEST + RELEASE** stages.

## Your auth-service today
- ✅ GitHub Actions CI: `mvn test` + Docker build
- 🔲 CD to Azure (not yet connected)

## Concepts to master

| Concept | Explanation |
|---------|-------------|
| **CI vs CD** | CI = integrate & test often. CD = deploy automatically to environments |
| **Pipeline stages** | Build → Test → Package → Deploy → Verify |
| **Artifacts** | JAR, Docker image stored between stages |
| **Environments** | dev → staging → prod with approvals |
| **Triggers** | Push to `main`, PR, manual, scheduled |
| **Secrets in CI** | Never in code; use GitHub Secrets / Azure Key Vault |
| **Idempotent deploys** | Same pipeline, same result every time |

## Tools comparison (interview)

| Tool | When to mention |
|------|-----------------|
| **GitHub Actions** | Your project; OSS, YAML in repo |
| **Azure DevOps Pipelines** | Enterprise; Azure Repos, Boards integration |
| **Azure Pipelines** | Same as DevOps; hybrid cloud/on-prem agents |

## Hands-on lab (office Azure)

### Week 1: CI deep dive
1. Read `.github/workflows/ci.yml` line by line
2. Break a test on purpose → watch CI fail
3. Fix → watch CI pass
4. Understand: checkout, JDK, Maven cache, Docker build

### Week 2: CD setup
1. Azure Container Registry in `rg-arun-learning-dev`
2. GitHub Actions CD: build → push to ACR → update Container App
3. Or Azure DevOps pipeline from `auth-service/azure-pipelines/`

## Interview Q&A

**Q: What is the difference between CI and CD?**  
A: CI automatically builds and tests on every commit. CD automatically deploys passing builds to environments. CI answers "does it work?" CD answers "ship it."

**Q: How does your auth-service CI work?**  
A: GitHub Actions runs on push/PR — Maven tests, packages JAR, validates Docker image. CD pushes to ACR and updates Container App on merge to main.

**Q: Where do you store pipeline secrets?**  
A: GitHub Encrypted Secrets for CI. Production secrets in Azure Key Vault, referenced at deploy time.

**Q: How do you handle failed deployments?**  
A: Health check after deploy, rollback to previous Container App revision, alerts on failure.

## Checkpoint ✅
- [ ] Explain CI/CD flow for auth-service in 2 minutes
- [ ] CI pipeline passes on GitHub
- [ ] One successful CD deploy to Azure (office)

---

# PHASE 2 — Deploy + Key Vault + Monitor (Weeks 3–4)

## 2A — Azure Spring Apps OR Container Apps

### What it is
**PaaS for running Java/Spring Boot** without managing servers.

### Spring Apps vs Container Apps (interview gold)

| | Azure Spring Apps | Azure Container Apps |
|--|-------------------|----------------------|
| **Best for** | Spring Boot native | Any container |
| **Java optimizations** | Built-in (Actuator, config) | Generic |
| **Complexity** | Medium | Lower |
| **Cost** | Higher | Lower |
| **Your project** | Try in Week 11 | Start here (Week 3) |

### Concepts
- **Revision** — immutable deploy unit; rollback = activate old revision
- **Ingress** — public HTTPS URL
- **Scale rules** — HTTP concurrency, CPU, custom metrics
- **VNet integration** — private networking to DB

### Hands-on (Week 3)
1. Deploy auth-service to **Container Apps** (portal guide)
2. Set env vars for DB, Redis, JWT
3. Hit `/actuator/health` on public URL
4. Register + login via Postman against Azure URL

---

## 2B — Azure Key Vault

### What it is
Centralized **secret, key, and certificate** storage with access control and audit logs.

### SDLC role
**RELEASE + OPERATE** — secrets never in code or plain env files.

### Concepts

| Concept | Use in auth-service |
|---------|---------------------|
| **Secrets** | JWT_SECRET, DB_PASSWORD, OAUTH2_CLIENT_SECRET |
| **Access policies / RBAC** | App identity can read; humans cannot |
| **Managed Identity** | App authenticates to Key Vault without passwords |
| **Secret rotation** | Update secret version; app picks up new value |
| **Reference in Spring Apps** | `@Microsoft.KeyVault(SecretUri=...)` |

### Architecture
```
auth-service (Managed Identity)
        │
        ▼ reads secrets
   Key Vault
   ├── jwt-secret
   ├── db-password
   └── oauth2-client-secret
```

### Hands-on (Week 4)
1. Create Key Vault in learning RG
2. Add secrets: `jwt-secret`, `db-password`
3. Enable **System-assigned managed identity** on Container App
4. Grant identity **Key Vault Secrets User** role
5. Reference secrets in app config (env or Spring Cloud Azure)

### Interview Q&A

**Q: Why Key Vault instead of environment variables?**  
A: Centralized management, audit trail, RBAC, rotation without redeploying code, no secrets in CI logs.

**Q: How does the app access Key Vault without a password?**  
A: Managed Identity — Azure AD issues a token; no credentials in config.

**Q: What secrets does auth-service need?**  
A: JWT signing key, database password, OAuth2 client secret, Redis password.

---

## 2C — Azure Monitor & Application Insights

### What it is
**Observability** — logs, metrics, distributed traces, alerts, dashboards.

### SDLC role
**OPERATE** — know when things break before users do.

### Concepts

| Concept | auth-service example |
|---------|---------------------|
| **Logs** | Login failures, exceptions, slow queries |
| **Metrics** | Request rate, response time, JVM heap |
| **Traces** | Request flow: APIM → app → DB |
| **Alerts** | Error rate > 5% → email/Teams |
| **Dashboards** | Health overview for ops |
| **Spring Boot integration** | `applicationinsights-spring-boot-starter` |

### What to monitor in auth-service

| Signal | Alert on |
|--------|----------|
| HTTP 5xx rate | > 1% for 5 min |
| `/actuator/health` | Down |
| Login latency p95 | > 2 seconds |
| JVM memory | > 85% |
| Failed auth attempts spike | Possible attack |

### Hands-on (Week 4)
1. Create Application Insights resource
2. Copy connection string → Container App env var `APPLICATIONINSIGHTS_CONNECTION_STRING`
3. Add dependency to `pom.xml` (optional code change)
4. Generate traffic (Postman login loop)
5. View **Live Metrics** and **Failures** in portal
6. Create alert: availability < 100%

### Interview Q&A

**Q: Difference between Azure Monitor and Application Insights?**  
A: Monitor is the platform (metrics, alerts, logs). App Insights is an APM tool for application-level telemetry (requests, dependencies, exceptions).

**Q: How do you debug a production login failure?**  
A: App Insights → Failures → filter `/api/v1/auth/login` → see exception, trace ID → correlated logs → check DB/Redis connectivity.

**Q: What is the RED method?**  
A: Rate, Errors, Duration — three key metrics for any service.

## Checkpoint ✅
- [ ] auth-service running on Azure with public URL
- [ ] Key Vault storing at least 2 secrets
- [ ] Application Insights showing request data
- [ ] One alert configured

---

# PHASE 3 — API Management (Weeks 5–6)

## What it is
**API Gateway** — single front door for all APIs. Policies, security, documentation.

### SDLC role
**RELEASE + OPERATE** — govern how clients access auth-service.

## Why auth-service needs APIM (in real systems)

```
Clients (web, mobile, partners)
            │
            ▼
    ┌───────────────┐
    │     APIM      │
    │  /auth/*      │──▶ auth-service
    │  /users/*     │──▶ user-service
    │  /orders/*    │──▶ order-service
    └───────────────┘
```

## Concepts to master

| Concept | Explanation |
|---------|-------------|
| **API** | Group of operations (your auth endpoints) |
| **Product** | Bundle of APIs sold to consumers |
| **Subscription** | API key for a consumer |
| **Policies** | XML rules: rate limit, JWT validate, transform headers |
| **Revision** | Safe API changes without breaking consumers |
| **Developer portal** | Auto-generated API docs |

## APIM policies for auth-service (interview examples)

| Policy | Purpose |
|--------|---------|
| **Rate limit** | 100 logins/min per IP — prevent brute force |
| **Validate JWT** | On `/me`, `/logout` — check token before hitting app |
| **CORS** | Allow web frontend origins |
| **Request size limit** | Block oversized payloads |
| **Cache GET** | Cache `/me` briefly (careful with auth!) |

## Architecture with APIM

```
Client → APIM (https://api.mycompany.com/auth/login)
              │
              ▼ policy: rate-limit, cors
         auth-service (internal URL, not public)
```

## Hands-on (Week 5–6)

> ⚠️ APIM Developer tier ~$50/month — use office Azure, delete after lab.

1. Create APIM instance (Developer tier)
2. **Import API** from OpenAPI: `https://YOUR-APP/swagger-ui/v3/api-docs`
3. Set backend URL to auth-service internal URL
4. Add policies:
   - Rate limit on `/login`
   - CORS policy
5. Test via APIM gateway URL in Postman
6. Publish to Developer Portal
7. **Delete APIM** when lab complete (expensive)

## Interview Q&A

**Q: Why APIM if auth-service already has Spring Security?**  
A: APIM handles cross-cutting concerns at the edge — rate limiting, API keys, versioning, analytics — without changing each microservice. Defense in depth.

**Q: APIM vs Application Gateway?**  
A: APIM = API-level (OAuth, rate limits, developer portal). App Gateway = network-level (load balancing, WAF, SSL). Often used together: Gateway → APIM → services.

**Q: How do you version APIs in APIM?**  
A: URL path (`/v1/auth/login`), header, or query param. APIM revisions allow safe rollout.

## Checkpoint ✅
- [ ] Explain APIM value for microservices
- [ ] Imported auth-service OpenAPI into APIM
- [ ] Applied rate-limit policy on login
- [ ] Tested through APIM gateway URL

---

# PHASE 4 — Messaging: Service Bus & Event Hubs (Weeks 7–8)

## What it is

| Service | Pattern | Use case |
|---------|---------|----------|
| **Azure Service Bus** | Message queue / pub-sub | Commands, async tasks |
| **Azure Event Hubs** | Event streaming (Kafka-like) | High-volume event streams, analytics |

## SDLC role
**OPERATE + integrate** — decouple auth-service from other services.

## Why auth-service would publish events

```
User registers
      │
      ▼
auth-service ──publish──▶ Service Bus topic: "user-events"
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
              email-svc  analytics  user-profile-svc
```

### Example events from auth-service

| Event | When | Consumer |
|-------|------|----------|
| `UserRegistered` | POST /register | Send welcome email |
| `UserLoggedIn` | POST /login | Audit log, analytics |
| `UserLoggedOut` | POST /logout | Session cleanup |
| `TokenRefreshed` | POST /refresh | Security monitoring |

## Service Bus concepts

| Concept | Explanation |
|---------|-------------|
| **Queue** | 1:1 — one consumer processes each message |
| **Topic + Subscriptions** | 1:many — multiple consumers |
| **Dead letter queue** | Failed messages after retries |
| **Sessions** | Ordered processing |
| **Peek-lock** | Message hidden while processing |

## Event Hubs concepts

| Concept | Explanation |
|---------|-------------|
| **Event Hub** | Stream of events |
| **Partitions** | Parallelism units |
| **Consumer groups** | Independent readers of same stream |
| **Retention** | Keep events for replay (1–90 days) |

## Service Bus vs Event Hubs (interview)

| | Service Bus | Event Hubs |
|--|-------------|------------|
| **Volume** | Thousands/sec | Millions/sec |
| **Pattern** | Commands, workflows | Event sourcing, analytics |
| **Ordering** | Sessions (queues) | Per partition |
| **Replay** | No | Yes |
| **auth-service use** | ✅ UserRegistered event | Analytics pipeline |

## Hands-on (Week 7–8)

### Lab 1: Service Bus
1. Create Service Bus namespace + topic `user-events`
2. Add subscription `email-service-sub`
3. In auth-service (small code addition):
   - After register, publish `UserRegistered` JSON message
4. Use **Service Bus Explorer** in portal to see messages
5. Delete namespace after lab

### Lab 2: Event Hubs (conceptual)
1. Create Event Hub `auth-analytics`
2. Publish login events (or use portal test tool)
3. View metrics: incoming messages
4. Understand when you'd choose this over Service Bus

## Interview Q&A

**Q: When would auth-service use async messaging?**  
A: After registration, publish event so email service sends welcome mail without blocking the HTTP response. Improves latency and decouples services.

**Q: How do you handle message failures?**  
A: Retry with exponential backoff → dead letter queue → alert ops → manual replay after fix.

**Q: Service Bus vs Kafka vs Event Hubs?**  
A: Event Hubs is Azure's Kafka-compatible streaming service. Service Bus is for enterprise messaging patterns (queues, topics, transactions).

## Checkpoint ✅
- [ ] Explain async event after user registration
- [ ] Created Service Bus topic + saw a message in portal
- [ ] Know when to pick Service Bus vs Event Hubs

---

# PHASE 5 — Application Gateway (Weeks 9–10)

## What it is
**Layer 7 load balancer** with optional **WAF** (Web Application Firewall).

## SDLC role
**DEPLOY + OPERATE** — secure entry point, SSL, routing to multiple backends.

## Architecture (full stack)

```
Internet
    │
    ▼
Application Gateway (WAF enabled)
    │  SSL termination (*.mycompany.com)
    │  Rules: /auth/* → APIM or Spring App
    │         /api/*  → APIM
    ▼
APIM / Spring Apps (internal)
```

## Concepts

| Concept | Explanation |
|---------|-------------|
| **Listener** | Accepts HTTPS on port 443 |
| **Backend pool** | auth-service instances |
| **Routing rule** | Path `/auth/*` → auth backend |
| **WAF** | Block SQL injection, XSS on login endpoint |
| **SSL termination** | Gateway handles HTTPS; backend HTTP internal |
| **Health probe** | `/actuator/health` — remove unhealthy instances |

## WAF rules relevant to auth-service

| Rule | Protects against |
|------|------------------|
| SQL injection | Malicious login payloads |
| Rate limiting (WAF) | DDoS on /login |
| Geo-filtering | Block countries if needed |
| Bot protection | Automated credential stuffing |

## Hands-on (Week 9–10)

> ⚠️ App Gateway is **expensive** (~$150+/month). Office Azure only; delete same day.

1. Understand architecture via Microsoft Learn (theory-heavy week)
2. If office budget allows: create App Gateway → point to Container App
3. Configure health probe: `/actuator/health`
4. Enable WAF on OWASP rules
5. Test: normal login works; malicious SQL string blocked
6. **Delete immediately** after lab

## Interview Q&A

**Q: App Gateway vs APIM vs Spring Security?**  
A: Three layers. App Gateway = network (SSL, WAF, LB). APIM = API governance (rate limits, keys). Spring Security = application auth (JWT, OAuth). All three together = defense in depth.

**Q: Where does SSL terminate?**  
A: Ideally at App Gateway or APIM. Backend services use HTTP on internal network (VNet).

**Q: How does health probe work?**  
A: Gateway pings `/actuator/health` every 30s. Failing backends removed from rotation automatically.

## Checkpoint ✅
- [ ] Draw full architecture: Gateway → APIM → Spring App → DB
- [ ] Explain WAF value for login endpoint
- [ ] Know cost implications (why not always used in dev)

---

# PHASE 6 — Azure Spring Apps + Full Integration (Weeks 11–12)

## What it is
Microsoft-managed **Spring Boot platform** — deploy JARs or containers with Spring optimizations.

## Why learn it (Java interviews)
Many enterprises use it. Know how it differs from Container Apps.

## Spring Apps concepts

| Concept | Explanation |
|---------|-------------|
| **App** | Your auth-service deployment |
| **Deployment** | Blue/green, rolling updates |
| **Custom domain** | auth.mycompany.com |
| **VNet injection** | Private DB access |
| **Spring Cloud integration** | Config Server, Service Registry |
| **Built-in logging** | Direct to Log Analytics |
| **Tanzu components** | Optional (Config, Service Registry) |

## Migrate auth-service to Spring Apps

1. Create Spring Apps service in portal
2. Deploy from ACR or GitHub Actions
3. Configure env vars / Key Vault references
4. Enable App Insights
5. Compare experience vs Container Apps

## Full integrated architecture (final state)

```
                    ┌─────────────────┐
                    │ App Gateway+WAF │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │      APIM       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Azure Spring    │
                    │ Apps            │
                    │ auth-service    │
                    └──┬──────┬───┬──┘
                       │      │   │
              ┌────────▼┐ ┌───▼┐ ┌▼──────────┐
              │Key Vault│ │ PG │ │Redis      │
              └─────────┘ └────┘ └───────────┘
                       │
              ┌────────▼────────┐
              │  Service Bus    │
              │  user-events    │
              └─────────────────┘
                       │
              ┌────────▼────────┐
              │ App Insights +  │
              │ Azure Monitor   │
              └─────────────────┘

        GitHub Actions CI/CD ──▶ ACR ──▶ Spring Apps
```

## Week 12: Mock interview week

Practice explaining entire SDLC for auth-service:

### 2-minute elevator pitch
> "I built an OAuth2 authentication microservice in Spring Boot with JWT and refresh tokens. The CI pipeline in GitHub Actions runs tests and builds a Docker image on every PR. CD deploys to Azure Spring Apps via ACR. Secrets are in Key Vault with managed identity. APIM sits in front for rate limiting and API governance. User registration publishes events to Service Bus for downstream services. Application Gateway handles SSL and WAF. Everything is monitored through Application Insights with alerts on error rate and availability."

---

# Certification alignment

| Certification | Covers | When |
|---------------|--------|------|
| **AZ-900** | Fundamentals | Week 1–2 (parallel) |
| **AZ-204** | Developer — all topics above | After Week 8 |
| **AZ-305** | Architect — App Gateway, networking | Optional later |

---

# Weekly schedule template

| Week | Topic | Hands-on | Hours |
|------|-------|----------|-------|
| 1 | CI fundamentals | Fix CI, read pipeline YAML | 4 |
| 2 | CD to Azure | Deploy via GitHub Actions | 4 |
| 3 | Container Apps deploy | Portal deploy, Postman test | 4 |
| 4 | Key Vault + App Insights | Secrets + monitoring + alert | 5 |
| 5 | APIM basics | Import OpenAPI, test gateway | 5 |
| 6 | APIM policies | Rate limit, CORS, JWT validate | 4 |
| 7 | Service Bus | Publish UserRegistered event | 5 |
| 8 | Event Hubs | Compare, analytics scenario | 3 |
| 9 | App Gateway theory | Learn modules, draw architecture | 4 |
| 10 | App Gateway lab | WAF + health probe (office) | 4 |
| 11 | Azure Spring Apps | Deploy + compare Container Apps | 5 |
| 12 | Mock interviews | Full architecture explanation | 6 |

**Total: ~53 hours over 12 weeks**

---

# Top 30 interview questions (master list)

## CI/CD
1. CI vs CD?
2. How does your pipeline work?
3. Where are secrets stored in CI?
4. How do you rollback a bad deploy?
5. Blue/green vs rolling deployment?

## Spring Apps / Compute
6. Spring Apps vs Container Apps vs AKS?
7. What is a revision?
8. How do you scale auth-service?
9. How does health check work?

## Key Vault
10. Why Key Vault over env vars?
11. What is managed identity?
12. How do you rotate JWT secret?

## Monitor / App Insights
13. Monitor vs App Insights?
14. How do you debug production login failure?
15. What alerts would you set?
16. RED method?

## API Management
17. Why APIM for microservices?
18. APIM vs App Gateway?
19. How do you rate-limit login?
20. API versioning strategies?

## Messaging
21. When does auth-service publish async events?
22. Service Bus vs Event Hubs?
23. What is dead letter queue?
24. How ensure message processed exactly once?

## Application Gateway
25. Layer 4 vs Layer 7 load balancing?
26. What does WAF protect against?
27. Where does SSL terminate?

## Architecture
28. Draw auth-service architecture end-to-end
29. How do you handle secrets across environments?
30. How do you control Azure costs?

---

# Resume bullet points (copy when ready)

```
• Built OAuth2/JWT authentication microservice (Spring Boot 3, PostgreSQL, Redis)
• Implemented CI/CD with GitHub Actions: automated test, Docker build, deploy to Azure
• Deployed to Azure Spring Apps / Container Apps with Key Vault for secret management
• Integrated Application Insights for distributed tracing, metrics, and alerting
• Designed event-driven architecture using Azure Service Bus for user lifecycle events
• Exposed APIs through Azure API Management with rate limiting and OAuth policies
```

---

# Cost guide (office Azure labs)

| Service | Lab duration | Action |
|---------|-------------|--------|
| Container Apps | Per session | Delete revision |
| Key Vault | Keep | Cheap, leave running |
| App Insights | Keep | Free tier |
| APIM Developer | 1 day | Delete after |
| Service Bus | 1 day | Delete after |
| App Gateway | 2 hours | Delete immediately |
| Spring Apps | 1–2 days | Delete after comparison |

**Rule:** One expensive service per week. Delete when done.

---

# Your next action (start Monday)

1. ✅ Phase 1–2 done (local + CI)
2. **This week:** Deploy auth-service to Container Apps on office Azure
3. **Next week:** Key Vault + Application Insights
4. Study AZ-900 in parallel (Microsoft Learn, free)

**First portal task:** Create `rg-arun-learning-dev` → follow `PHASE-3-AZURE-PORTAL.md`

---

*You have the code. Now build the cloud story around it. That's what gets you hired.*
