# Azure Deployment Guide

This guide covers CI/CD pipelines and deploying **auth-service** to Azure using:

- **Azure Container Registry (ACR)** — Docker images
- **Azure Container Apps** — run the microservice
- **Azure Database for PostgreSQL** — user & token storage
- **Azure Cache for Redis** — token blacklist
- **GitHub Actions** or **Azure DevOps** — CI/CD

---

## Architecture

```
GitHub / Azure DevOps
        │
        ▼
   ┌─────────┐     ┌──────────────┐
   │   CI    │────▶│     ACR      │
   │ (test)  │     │ Docker image │
   └─────────┘     └──────┬───────┘
        │                  │
        ▼                  ▼
   ┌─────────┐     ┌──────────────────┐
   │   CD    │────▶│ Container Apps   │
   └─────────┘     │  (auth-service)  │
                   └────────┬─────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        PostgreSQL       Redis        Key Vault
```

---

## Prerequisites

1. [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed
2. Azure subscription with Contributor access
3. GitHub repo (for GitHub Actions) **or** Azure DevOps project
4. Secrets generated locally:

```powershell
# JWT secret (base64, 64 bytes)
[Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])

# Or with OpenSSL (Git Bash)
openssl rand -base64 64
```

---

## Step 1: One-time Azure setup (CLI)

```powershell
# Login
az login

# Set variables
$RESOURCE_GROUP = "rg-auth-service-dev"
$LOCATION = "eastus"
$ENVIRONMENT = "dev"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Generate secrets (save these securely!)
$POSTGRES_PASSWORD = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
$JWT_SECRET = [Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
$OAUTH2_SECRET = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

# Build and push initial image (required before first infra deploy)
cd auth-service
mvn clean package -DskipTests

# Deploy infrastructure (creates ACR, DB, Redis, Container App)
az deployment group create `
  --resource-group $RESOURCE_GROUP `
  --template-file azure/main.bicep `
  --parameters `
    environment=$ENVIRONMENT `
    location=$LOCATION `
    postgresAdminPassword=$POSTGRES_PASSWORD `
    jwtSecret=$JWT_SECRET `
    oauth2ClientSecret=$OAUTH2_SECRET `
    containerImageTag=bootstrap

# Get ACR name from deployment output
$ACR_NAME = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.acrName.value" -o tsv
$ACR_LOGIN = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.acrLoginServer.value" -o tsv

# Login to ACR and push first image
az acr login --name $ACR_NAME
docker build -t "$ACR_LOGIN/auth-service:latest" .
docker push "$ACR_LOGIN/auth-service:latest"

# Update container app with real image
$APP_NAME = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.containerAppName.value" -o tsv
az containerapp update --name $APP_NAME --resource-group $RESOURCE_GROUP --image "$ACR_LOGIN/auth-service:latest"

# Get app URL
az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.containerAppUrl.value" -o tsv
```

> **Note:** First Bicep deploy may fail if the image tag doesn't exist in ACR yet. Push the image first using `containerImageTag=latest` after building, or run infra deploy then push + update as shown above.

---

## Step 2: GitHub Actions setup

### 2a. Create Azure Service Principal (OIDC — recommended)

```powershell
$APP_ID = az ad app create --display-name "github-auth-service" --query appId -o tsv
$SP_ID = az ad sp create --id $APP_ID --query id -o tsv

# Replace with your GitHub org/repo
$GITHUB_ORG = "your-org"
$GITHUB_REPO = "your-repo"

az ad app federated-credential create `
  --id $APP_ID `
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Assign Contributor on resource group
az role assignment create `
  --role Contributor `
  --assignee $APP_ID `
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"
```

### 2b. GitHub repository secrets

Go to **Settings → Secrets and variables → Actions**

**Secrets:**

| Secret | Value |
|--------|-------|
| `AZURE_CLIENT_ID` | Service principal app ID |
| `AZURE_TENANT_ID` | `az account show --query tenantId -o tsv` |
| `AZURE_SUBSCRIPTION_ID` | `az account show --query id -o tsv` |
| `POSTGRES_ADMIN_PASSWORD` | Your DB password |
| `JWT_SECRET` | Base64 JWT secret |
| `OAUTH2_CLIENT_SECRET` | OAuth2 client secret |

**Variables (per environment `dev`):**

| Variable | Example |
|----------|---------|
| `AZURE_RESOURCE_GROUP` | `rg-auth-service-dev` |
| `ACR_NAME` | from deployment output |
| `ACR_LOGIN_SERVER` | `myacr.azurecr.io` |
| `CONTAINER_APP_NAME` | `authdev-app` |

### 2c. Pipelines

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `.github/workflows/ci.yml` | PR / push | Run tests, validate Docker build |
| `.github/workflows/cd-azure.yml` | Push to `main` | Build, push to ACR, deploy |
| `.github/workflows/cd-infrastructure.yml` | Manual | Provision/update Azure infra |

---

## Step 3: Azure DevOps setup

1. **Project → Pipelines → New pipeline**
2. Import `auth-service/azure-pipelines/ci.yml` for CI
3. Import `auth-service/azure-pipelines/cd.yml` for CD

### Required setup

| Item | Description |
|------|-------------|
| Service connection | Azure Resource Manager (OIDC) |
| ACR service connection | Docker Registry → your ACR |
| Variable group `auth-service-dev` | `ACR_NAME`, `ACR_LOGIN_SERVER`, `AZURE_RESOURCE_GROUP`, `CONTAINER_APP_NAME` |
| Environment | `auth-service-dev` with approval gates (optional) |

---

## Step 4: Verify deployment

```powershell
$APP_URL = az containerapp show `
  --name authdev-app `
  --resource-group rg-auth-service-dev `
  --query "properties.configuration.ingress.fqdn" -o tsv

Invoke-RestMethod -Uri "https://$APP_URL/actuator/health"
```

Test register/login using the Postman collection — replace `localhost:8080` with your Azure URL.

---

## CI/CD flow summary

```
Developer pushes code
        │
        ▼
┌───────────────────┐
│  CI Pipeline      │
│  • mvn test       │
│  • mvn package    │
│  • docker build   │
└─────────┬─────────┘
          │ (on merge to main)
          ▼
┌───────────────────┐
│  CD Pipeline      │
│  • docker push    │
│  • update app     │
│  • health check   │
└───────────────────┘
```

---

## Cost estimate (dev environment)

| Resource | SKU | ~Monthly cost |
|----------|-----|---------------|
| Container Apps | 0.5 vCPU, 1GB | $15–30 |
| PostgreSQL Flexible | B1ms | $12–15 |
| Redis Cache | Basic C0 | $16 |
| ACR | Basic | $5 |
| Log Analytics | Pay per GB | $2–5 |
| **Total** | | **~$50–70/mo** |

Use `az group delete --name rg-auth-service-dev` to tear down when not needed.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Container app won't start | `az containerapp logs show -n <app> -g <rg> --follow` |
| DB connection failed | Check `DB_SSLMODE=require`, firewall allows Azure services |
| Redis SSL error | Ensure `REDIS_SSL_ENABLED=true` and port `6380` |
| ACR pull denied | Verify managed identity has `AcrPull` role on ACR |
| Health check timeout | App needs 60–90s for Flyway migrations on first start |

---

## Files reference

```
.github/workflows/
  ci.yml                  # Build & test on PR
  cd-azure.yml            # Deploy app on main
  cd-infrastructure.yml   # Provision Azure (manual)

auth-service/azure-pipelines/
  ci.yml                  # Azure DevOps CI
  cd.yml                  # Azure DevOps CD

auth-service/azure/
  main.bicep              # Infrastructure as code
  main.parameters.dev.example.json
```
