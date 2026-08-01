# Phase 3: Deploy auth-service to Azure (Learning Guide)

Deploy your auth-service to Azure using **free trial credits** (~$200 for 30 days).

**Estimated time:** 45–60 minutes  
**Estimated cost:** $0 with free credits (delete resources when done!)

---

## Before you start

| Requirement | Check |
|-------------|-------|
| Phase 1 complete | Local app works |
| Phase 2 complete | GitHub CI passes |
| Azure account | [azure.com/free](https://azure.microsoft.com/free/) |
| Azure CLI | `az --version` |
| Docker Desktop | Running |
| Java 21 + Maven | `mvn -version` |

---

## Step 1: Install Azure CLI (if needed)

```powershell
winget install Microsoft.AzureCLI
```

Close and reopen PowerShell, then:

```powershell
az login
```

A browser opens — sign in with your Azure account.

Verify:

```powershell
az account show --query "{name:name, id:id}" -o table
```

---

## Step 2: Set your variables

Copy and run in PowerShell (customize if you want):

```powershell
$RESOURCE_GROUP = "rg-auth-service-dev"
$LOCATION       = "eastus"          # or "centralindia", "westeurope", etc.
$ENVIRONMENT    = "dev"
```

---

## Step 3: Create resource group

```powershell
az group create --name $RESOURCE_GROUP --location $LOCATION
```

---

## Step 4: Generate secrets (save these!)

```powershell
$POSTGRES_PASSWORD = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
$JWT_SECRET        = [Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
$OAUTH2_SECRET     = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

Write-Host "SAVE THESE SECRETS SECURELY:"
Write-Host "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
Write-Host "JWT_SECRET:        $JWT_SECRET"
Write-Host "OAUTH2_SECRET:     $OAUTH2_SECRET"
```

Copy the output to a password manager or notepad — you'll need these later.

---

## Step 5: Build the JAR locally

```powershell
cd "D:\workspace\cursor\java-azure deployments\auth-service"
mvn clean package -DskipTests
```

---

## Step 6: Deploy Azure infrastructure

```powershell
az deployment group create `
  --resource-group $RESOURCE_GROUP `
  --template-file azure/main.bicep `
  --parameters `
    environment=$ENVIRONMENT `
    location=$LOCATION `
    postgresAdminPassword=$POSTGRES_PASSWORD `
    jwtSecret=$JWT_SECRET `
    oauth2ClientSecret=$OAUTH2_SECRET `
    containerImageTag=latest
```

This takes **10–15 minutes**. It creates:
- Container Registry (ACR)
- PostgreSQL database
- Redis cache
- Container App
- Log Analytics

> **Note:** First deploy may show Container App as unhealthy until you push the Docker image (Step 7).

---

## Step 7: Push Docker image to ACR

```powershell
$ACR_NAME  = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.acrName.value" -o tsv
$ACR_LOGIN = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.acrLoginServer.value" -o tsv

Write-Host "ACR: $ACR_LOGIN"

az acr login --name $ACR_NAME

docker build -t "$ACR_LOGIN/auth-service:latest" .
docker push "$ACR_LOGIN/auth-service:latest"
```

---

## Step 8: Update Container App with the image

```powershell
$APP_NAME = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.containerAppName.value" -o tsv

az containerapp update `
  --name $APP_NAME `
  --resource-group $RESOURCE_GROUP `
  --image "$ACR_LOGIN/auth-service:latest"
```

Wait 1–2 minutes for the app to start.

---

## Step 9: Get your public URL and test

```powershell
$APP_URL = az deployment group show -g $RESOURCE_GROUP -n main --query "properties.outputs.containerAppUrl.value" -o tsv
Write-Host "Your app is live at: $APP_URL"

# Health check
Invoke-RestMethod -Uri "$APP_URL/actuator/health"
```

### Test register & login (replace URL)

```powershell
$body = '{"email":"azure@example.com","password":"password123","firstName":"Azure","lastName":"User"}'
Invoke-RestMethod -Uri "$APP_URL/api/v1/auth/register" -Method POST -ContentType "application/json" -Body $body

$login = '{"email":"azure@example.com","password":"password123"}'
$tokens = Invoke-RestMethod -Uri "$APP_URL/api/v1/auth/login" -Method POST -ContentType "application/json" -Body $login
$tokens
```

---

## Step 10: View logs (if something fails)

```powershell
az containerapp logs show --name $APP_NAME --resource-group $RESOURCE_GROUP --follow
```

---

## IMPORTANT: Delete resources when done (stop billing!)

```powershell
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

This deletes **everything** and stops all charges.

---

## Optional: One-script deploy (CLI)

We included an automated script for CLI users:

```powershell
cd auth-service/scripts
.\azure-phase3.ps1 -ResourceGroup "rg-auth-service-dev" -Location "eastus"
```

> **Prefer the portal?** See [PHASE-3-AZURE-PORTAL.md](PHASE-3-AZURE-PORTAL.md) — full step-by-step with no CLI.

---

## Optional: GitHub Actions CD (Phase 3b)

After manual deploy works, automate with GitHub CD. See [AZURE-DEPLOYMENT.md](AZURE-DEPLOYMENT.md) for:
- Azure OIDC setup for GitHub
- GitHub secrets & variables
- Enabling `.github/workflows/cd-azure.yml`

---

## Phase 3 checklist

- [ ] Azure account created
- [ ] `az login` works
- [ ] Resource group created
- [ ] Bicep deployment succeeded
- [ ] Docker image pushed to ACR
- [ ] Container App updated
- [ ] `/actuator/health` returns `UP`
- [ ] Register + login works on public URL
- [ ] Resource group deleted after learning session

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `az: command not found` | Install Azure CLI, restart terminal |
| Bicep deploy fails on region | Try `eastus` or `centralindia` |
| Container App unhealthy | Push image (Step 7) and update (Step 8) |
| DB connection error | Wait 5 min for PostgreSQL to fully provision |
| `403 on az acr login` | Run `az login` again |
| Unexpected charges | `az group delete --name rg-auth-service-dev --yes` |

---

## What's next (Phase 4)

- Set up GitHub Actions CD for automatic deploy on push
- Add custom domain
- Configure monitoring alerts
- Use Azure Key Vault for secrets
