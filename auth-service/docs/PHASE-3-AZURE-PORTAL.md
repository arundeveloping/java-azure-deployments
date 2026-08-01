# Phase 3: Deploy using Azure Portal (No CLI)

Learn Azure by clicking through the portal — no command line required.

**Your GitHub repo:** `https://github.com/arundeveloping/java-azure-deployments`

**Estimated time:** 60–90 minutes  
**Cost:** $0 with [Azure free account](https://azure.microsoft.com/free/) ($200 credit for 30 days)

---

## What you'll create in the portal

```
Resource Group: rg-auth-service-dev
├── Azure Container Registry   (stores Docker image)
├── PostgreSQL Flexible Server (database)
├── Azure Cache for Redis      (token blacklist)
├── Container Apps Environment (hosting platform)
└── Container App              (runs auth-service)
```

---

## Part 1: Sign up and open the portal

1. Go to [azure.microsoft.com/free](https://azure.microsoft.com/free/) and create a free account
2. Open [portal.azure.com](https://portal.azure.com)
3. Confirm you're on the **Free Trial** or **Pay-As-You-Go** subscription (top-right profile → Subscriptions)

---

## Part 2: Create a Resource Group

A resource group is a folder for all your Azure resources.

1. In the portal search bar, type **Resource groups** → click it
2. Click **+ Create**
3. Fill in:
   | Field | Value |
   |-------|-------|
   | Subscription | Your free trial subscription |
   | Resource group | `rg-auth-service-dev` |
   | Region | `East US` (or nearest to you) |
4. Click **Review + create** → **Create**

---

## Part 3: Create PostgreSQL Database

1. Search **Azure Database for PostgreSQL flexible servers** → **+ Create**
2. **Basics** tab:

   | Field | Value |
   |-------|-------|
   | Resource group | `rg-auth-service-dev` |
   | Server name | `authdev-pg` + your initials (must be globally unique, e.g. `authdev-pgarun`) |
   | Region | Same as resource group |
   | PostgreSQL version | `16` |
   | Workload type | `Development` |
   | Compute + storage | **Burstable**, `Standard_B1ms` (cheapest) |
   | Storage | 32 GB |
   | Admin username | `authadmin` |
   | Password | Create a strong password — **save it!** |

3. Click **Networking** tab:
   - ✅ **Allow public access from any Azure service within Azure to this server**
   - Click **+ Add current client IP address** (so you can test from portal later)

4. Click **Review + create** → **Create** (takes ~5 minutes)

5. After deployment, go to the PostgreSQL resource → **Databases** (left menu under Settings)
   - Click **+ Add**
   - Database name: `authdb`
   - Click **Save**

**Save these values:**
```
DB_HOST     = authdev-pgarun.postgres.database.azure.com  (your server name)
DB_PORT     = 5432
DB_NAME     = authdb
DB_USERNAME = authadmin
DB_PASSWORD = (your password)
```

---

## Part 4: Create Redis Cache

1. Search **Azure Cache for Redis** → **+ Create**
2. Fill in:

   | Field | Value |
   |-------|-------|
   | Resource group | `rg-auth-service-dev` |
   | DNS name | `authdev-redis` + initials (e.g. `authdev-redisarun`) |
   | Location | Same region |
   | Cache type | **Basic C0** (250 MB — cheapest) |
   | Non-TLS port | **Disabled** |

3. Click **Review + create** → **Create** (takes ~5 minutes)

4. After deployment, open the Redis resource → **Authentication** (left menu)
   - Copy **Primary connection string** or note:
     - **Host name:** `authdev-redisarun.redis.cache.windows.net`
     - **SSL port:** `6380`
     - **Primary access key:** (click Show → copy)

**Save these values:**
```
REDIS_HOST     = authdev-redisarun.redis.cache.windows.net
REDIS_PORT     = 6380
REDIS_PASSWORD = (primary access key)
REDIS_SSL      = true
```

---

## Part 5: Create Container Registry (ACR)

ACR stores your Docker image.

1. Search **Container registries** → **+ Create**
2. Fill in:

   | Field | Value |
   |-------|-------|
   | Resource group | `rg-auth-service-dev` |
   | Registry name | `authdevacr` + initials (e.g. `authdevacrarun`) — lowercase, no hyphens |
   | Location | Same region |
   | SKU | **Basic** |

3. Click **Review + create** → **Create**

4. After deployment, open the ACR resource → **Access keys** (left menu)
   - ✅ Enable **Admin user**
   - Copy **Login server** (e.g. `authdevacrarun.azurecr.io`)
   - Copy **Username** and **password**

---

## Part 6: Build & push Docker image

You have two portal-friendly options. Pick **Option A** if you want zero local tools.

### Option A: Build from GitHub in ACR (recommended — no Docker needed)

1. Open your ACR resource → **Services** → **Tasks** (left menu)
2. Click **+ Create**
3. Fill in:

   | Field | Value |
   |-------|-------|
   | Task name | `build-auth-service` |
   | Platform | Linux |
   | Source context | `https://github.com/arundeveloping/java-azure-deployments` |
   | Branch | `main` |
   | Dockerfile path | `auth-service/Dockerfile` |
   | Image names | `auth-service:latest` |

4. Click **Create** → wait for build to complete (5–10 min)
5. Go to **Repositories** (left menu) → confirm `auth-service` image exists

> **If ACR Tasks can't access your repo:** Make sure the repo is **public**, or connect GitHub under ACR → **Source control**.

### Option B: Use Docker Desktop on your PC (no Azure CLI)

Only if Option A fails:

1. Build JAR first — open PowerShell in your project:
   ```powershell
   cd "D:\workspace\cursor\java-azure deployments\auth-service"
   mvn clean package -DskipTests
   ```
2. Open **Docker Desktop**
3. In PowerShell:
   ```powershell
   docker login authdevacrarun.azurecr.io -u <ACR-username> -p <ACR-password>
   docker build -t authdevacrarun.azurecr.io/auth-service:latest .
   docker push authdevacrarun.azurecr.io/auth-service:latest
   ```
   (This uses Docker only — not Azure CLI)

---

## Part 7: Create Container Apps Environment

1. Search **Container Apps Environments** → **+ Create**
2. Fill in:

   | Field | Value |
   |-------|-------|
   | Resource group | `rg-auth-service-dev` |
   | Environment name | `authdev-env` |
   | Region | Same region |
   | Zone redundancy | **Disabled** (cheaper for learning) |

3. **Monitoring** tab: Create new Log Analytics workspace (default is fine)
4. Click **Review + create** → **Create**

---

## Part 8: Create the Container App

1. Search **Container Apps** → **+ Create**
2. **Basics** tab:

   | Field | Value |
   |-------|-------|
   | Resource group | `rg-auth-service-dev` |
   | Container app name | `authdev-app` |
   | Region | Same region |
   | Container Apps Environment | `authdev-env` (select existing) |

3. **Container** tab → click the container row to edit:

   | Field | Value |
   |-------|-------|
   | Image source | Azure Container Registry |
   | Registry | Select your ACR |
   | Image | `auth-service` |
   | Image tag | `latest` |
   | CPU cores | `0.5` |
   | Memory | `1 Gi` |

4. **Ingress** tab:

   | Field | Value |
   |-------|-------|
   | Ingress | **Enabled** |
   | Ingress traffic | Accepting traffic from anywhere |
   | Target port | `8080` |

5. Click **Review + create** — **don't create yet!** Go back and add environment variables first.

---

## Part 9: Configure Environment Variables

Before creating (or after — via **Settings → Environment variables**):

Click **+ Add** for each row:

| Name | Value | Secret? |
|------|-------|---------|
| `SPRING_PROFILES_ACTIVE` | `prod` | No |
| `DB_HOST` | `authdev-pgarun.postgres.database.azure.com` | No |
| `DB_PORT` | `5432` | No |
| `DB_NAME` | `authdb` | No |
| `DB_USERNAME` | `authadmin` | No |
| `DB_PASSWORD` | *(your postgres password)* | **Yes** |
| `DB_SSLMODE` | `require` | No |
| `REDIS_HOST` | `authdev-redisarun.redis.cache.windows.net` | No |
| `REDIS_PORT` | `6380` | No |
| `REDIS_PASSWORD` | *(redis primary key)* | **Yes** |
| `REDIS_SSL_ENABLED` | `true` | No |
| `JWT_SECRET` | *(generate below)* | **Yes** |
| `OAUTH2_CLIENT_SECRET` | *(any random string)* | **Yes** |
| `OAUTH2_ISSUER_URI` | `https://authdev-app.<your-domain>` | No |

**Generate JWT_SECRET** (PowerShell one-liner):
```powershell
[Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
```

> For `OAUTH2_ISSUER_URI`: leave blank initially, update after app is created with the real URL from **Application URL** on the overview page.

6. Click **Review + create** → **Create** (takes 2–3 minutes)

---

## Part 10: Get your public URL and test

1. Open your **Container App** resource → **Overview**
2. Copy **Application URL** (e.g. `https://authdev-app.happygrass-12345678.eastus.azurecontainerapps.io`)

3. Update `OAUTH2_ISSUER_URI`:
   - Go to **Settings → Environment variables**
   - Set `OAUTH2_ISSUER_URI` = your Application URL (e.g. `https://authdev-app.happygrass-....azurecontainerapps.io`)
   - Click **Save** → app restarts

4. Test in browser:
   ```
   https://YOUR-APP-URL/actuator/health
   ```
   Expected: `{"status":"UP"}`

5. Test Swagger:
   ```
   https://YOUR-APP-URL/swagger-ui.html
   ```

6. Test with Postman — replace `localhost:8080` with your Azure URL in the collection.

---

## Part 11: View logs in the portal (when debugging)

1. Container App → **Monitoring** → **Log stream**
2. Or → **Monitoring** → **Logs** (Log Analytics queries)
3. Or → **Revision management** → select active revision → **Console log**

Common first-start issue: Flyway migrations take 30–60 seconds. Wait and refresh health check.

---

## Part 12: Delete everything when done (stop billing!)

1. Search **Resource groups** → click `rg-auth-service-dev`
2. Click **Delete resource group**
3. Type `rg-auth-service-dev` to confirm
4. Click **Delete**

All resources are removed. Billing stops.

---

## Portal navigation cheat sheet

| What you need | Portal search |
|---------------|---------------|
| All your resources | `rg-auth-service-dev` (resource group) |
| App URL | Container Apps → `authdev-app` → Overview |
| App logs | Container Apps → Log stream |
| Database | PostgreSQL flexible server |
| Redis keys | Redis → Authentication |
| Docker images | Container registries → Repositories |
| Restart app | Container Apps → Revision management → Restart |

---

## Phase 3 checklist (Portal)

- [ ] Azure free account created
- [ ] Resource group `rg-auth-service-dev` created
- [ ] PostgreSQL created + `authdb` database added
- [ ] Redis cache created
- [ ] Container Registry created + image built
- [ ] Container Apps Environment created
- [ ] Container App created with all env vars
- [ ] `/actuator/health` returns UP on public URL
- [ ] Register + login tested via Postman
- [ ] Resource group deleted after session

---

## Troubleshooting (Portal)

| Problem | Where to look | Fix |
|---------|---------------|-----|
| App won't start | Container App → Log stream | Check DB/Redis connection strings |
| 502 Bad Gateway | Wait 2 min, check health | App still starting / Flyway running |
| DB connection failed | PostgreSQL → Networking | Enable "Azure services" firewall rule |
| Redis SSL error | Environment variables | `REDIS_SSL_ENABLED=true`, port `6380` |
| Image pull failed | Container App → Events | Check ACR admin enabled, image exists |
| Can't find image in ACR | ACR → Repositories | Re-run ACR Task build |

---

## What's next (Phase 4)

Once portal deploy works, you can:
- Connect **GitHub Actions CD** for automatic deploys on push
- Add **Application Insights** for monitoring (portal: Create → Application Insights)
- Set up **custom domain** (Container App → Custom domains)

See [AZURE-DEPLOYMENT.md](AZURE-DEPLOYMENT.md) for GitHub CD setup.
