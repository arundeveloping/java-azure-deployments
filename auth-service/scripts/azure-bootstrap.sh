#!/usr/bin/env bash
# Bootstrap script: create Azure resources and deploy auth-service
# Usage: ./scripts/azure-bootstrap.sh <resource-group> <location> <environment>

set -euo pipefail

RESOURCE_GROUP="${1:-rg-auth-service-dev}"
LOCATION="${2:-eastus}"
ENVIRONMENT="${3:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Logging into Azure..."
az account show > /dev/null || az login

echo "==> Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

echo "==> Generating secrets..."
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)
JWT_SECRET=$(openssl rand -base64 64)
OAUTH2_SECRET=$(openssl rand -base64 32)

echo "==> Building application..."
cd "$PROJECT_DIR"
mvn -B clean package -DskipTests -q

echo "==> Deploying infrastructure..."
DEPLOYMENT=$(az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file azure/main.bicep \
  --parameters \
    environment="$ENVIRONMENT" \
    location="$LOCATION" \
    postgresAdminPassword="$POSTGRES_PASSWORD" \
    jwtSecret="$JWT_SECRET" \
    oauth2ClientSecret="$OAUTH2_SECRET" \
    containerImageTag="latest" \
  --query properties.outputs -o json)

ACR_NAME=$(echo "$DEPLOYMENT" | jq -r '.acrName.value')
ACR_LOGIN=$(echo "$DEPLOYMENT" | jq -r '.acrLoginServer.value')
APP_NAME=$(echo "$DEPLOYMENT" | jq -r '.containerAppName.value')
APP_URL=$(echo "$DEPLOYMENT" | jq -r '.containerAppUrl.value')

echo "==> Pushing Docker image to ACR..."
az acr login --name "$ACR_NAME"
docker build -t "$ACR_LOGIN/auth-service:latest" .
docker push "$ACR_LOGIN/auth-service:latest"

echo "==> Updating Container App..."
az containerapp update \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$ACR_LOGIN/auth-service:latest"

echo ""
echo "============================================"
echo " Deployment complete!"
echo " App URL:      $APP_URL"
echo " ACR:          $ACR_LOGIN"
echo " Resource Group: $RESOURCE_GROUP"
echo "============================================"
echo ""
echo "Save these secrets for CI/CD:"
echo "  POSTGRES_ADMIN_PASSWORD=$POSTGRES_PASSWORD"
echo "  JWT_SECRET=$JWT_SECRET"
echo "  OAUTH2_CLIENT_SECRET=$OAUTH2_SECRET"
