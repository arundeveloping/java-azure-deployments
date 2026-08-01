# Phase 3: One-click Azure deployment script (PowerShell)
# Usage: .\azure-phase3.ps1 -ResourceGroup "rg-auth-service-dev" -Location "eastus"

param(
    [string]$ResourceGroup = "rg-auth-service-dev",
    [string]$Location = "eastus",
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== Phase 3: Azure Deployment ===" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Location:       $Location"
Write-Host ""

# Step 1: Login check
Write-Host "[1/8] Checking Azure login..." -ForegroundColor Yellow
az account show > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in. Opening browser for az login..."
    az login
}

# Step 2: Create resource group
Write-Host "[2/8] Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --output none

# Step 3: Generate secrets
Write-Host "[3/8] Generating secrets..." -ForegroundColor Yellow
$PostgresPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
$JwtSecret        = [Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
$OAuth2Secret     = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })

$SecretsFile = Join-Path $ProjectRoot "azure-secrets.txt"
@"
SAVE THESE — created $(Get-Date -Format 'yyyy-MM-dd HH:mm')
POSTGRES_PASSWORD=$PostgresPassword
JWT_SECRET=$JwtSecret
OAUTH2_CLIENT_SECRET=$OAuth2Secret
RESOURCE_GROUP=$ResourceGroup
"@ | Out-File -FilePath $SecretsFile -Encoding UTF8
Write-Host "  Secrets saved to: $SecretsFile" -ForegroundColor Green

# Step 4: Build JAR
Write-Host "[4/8] Building JAR..." -ForegroundColor Yellow
Push-Location $ProjectRoot
mvn -B clean package -DskipTests -q
if ($LASTEXITCODE -ne 0) { throw "Maven build failed" }
Pop-Location

# Step 5: Deploy infrastructure
Write-Host "[5/8] Deploying Azure infrastructure (10-15 min)..." -ForegroundColor Yellow
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file (Join-Path $ProjectRoot "azure\main.bicep") `
    --parameters `
        environment=$Environment `
        location=$Location `
        postgresAdminPassword=$PostgresPassword `
        jwtSecret=$JwtSecret `
        oauth2ClientSecret=$OAuth2Secret `
        containerImageTag=latest `
    --output none

if ($LASTEXITCODE -ne 0) { throw "Bicep deployment failed" }

# Step 6: Get outputs
Write-Host "[6/8] Reading deployment outputs..." -ForegroundColor Yellow
$AcrName  = az deployment group show -g $ResourceGroup -n main --query "properties.outputs.acrName.value" -o tsv
$AcrLogin = az deployment group show -g $ResourceGroup -n main --query "properties.outputs.acrLoginServer.value" -o tsv
$AppName  = az deployment group show -g $ResourceGroup -n main --query "properties.outputs.containerAppName.value" -o tsv
$AppUrl   = az deployment group show -g $ResourceGroup -n main --query "properties.outputs.containerAppUrl.value" -o tsv

# Step 7: Push Docker image
Write-Host "[7/8] Building and pushing Docker image to ACR..." -ForegroundColor Yellow
az acr login --name $AcrName
docker build -t "${AcrLogin}/auth-service:latest" $ProjectRoot
docker push "${AcrLogin}/auth-service:latest"

# Step 8: Update Container App
Write-Host "[8/8] Updating Container App..." -ForegroundColor Yellow
az containerapp update `
    --name $AppName `
    --resource-group $ResourceGroup `
    --image "${AcrLogin}/auth-service:latest" `
    --output none

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "App URL:  $AppUrl"
Write-Host "Health:   $AppUrl/actuator/health"
Write-Host "Swagger:  $AppUrl/swagger-ui.html"
Write-Host ""
Write-Host "Test:" -ForegroundColor Cyan
Write-Host "  Invoke-RestMethod -Uri '$AppUrl/actuator/health'"
Write-Host ""
Write-Host "When done learning, DELETE resources to stop billing:" -ForegroundColor Red
Write-Host "  az group delete --name $ResourceGroup --yes"
Write-Host ""
Write-Host "Secrets saved in: $SecretsFile"
