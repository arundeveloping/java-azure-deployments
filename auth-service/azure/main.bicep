@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

@description('Base name for resources')
param baseName string = 'auth'

@description('PostgreSQL administrator login')
param postgresAdminLogin string = 'authadmin'

@secure()
@description('PostgreSQL administrator password')
param postgresAdminPassword string

@secure()
@description('JWT signing secret (base64-encoded, 64+ bytes)')
param jwtSecret string

@secure()
@description('OAuth2 client secret for the authorization server')
param oauth2ClientSecret string

@description('Container image tag to deploy')
param containerImageTag string = 'latest'

@description('Deployer IP for PostgreSQL firewall (optional, e.g. 1.2.3.4)')
param deployerIpAddress string = ''

var uniqueSuffix = uniqueString(resourceGroup().id)
var namePrefix = '${baseName}${environment}'
var acrName = take(replace('${namePrefix}acr${uniqueSuffix}', '-', ''), 50)
var postgresServerName = '${namePrefix}-pg-${take(uniqueSuffix, 8)}'
var redisName = '${namePrefix}-redis-${take(uniqueSuffix, 8)}'
var keyVaultName = take('${namePrefix}kv${uniqueSuffix}', 24)
var containerAppName = '${namePrefix}-app'
var logAnalyticsName = '${namePrefix}-logs'
var containerAppsEnvName = '${namePrefix}-cae'
var dbName = 'authdb'
var appFqdn = '${containerAppName}.${containerAppsEnv.properties.defaultDomain}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppsEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: postgresServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '16'
    administratorLogin: postgresAdminLogin
    administratorLoginPassword: postgresAdminPassword
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource postgresFirewallAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-12-01-preview' = {
  parent: postgres
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresFirewallDeployer 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-12-01-preview' = if (!empty(deployerIpAddress)) {
  parent: postgres
  name: 'AllowDeployer'
  properties: {
    startIpAddress: deployerIpAddress
    endIpAddress: deployerIpAddress
  }
}

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  parent: postgres
  name: dbName
}

resource redis 'Microsoft.Cache/redis@2024-03-01' = {
  name: redisName
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
      registries: [
        {
          server: acr.properties.loginServer
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'db-password'
          value: postgresAdminPassword
        }
        {
          name: 'jwt-secret'
          value: jwtSecret
        }
        {
          name: 'oauth2-client-secret'
          value: oauth2ClientSecret
        }
        {
          name: 'redis-password'
          value: redis.listKeys().primaryKey
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'auth-service'
          image: '${acr.properties.loginServer}/auth-service:${containerImageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            { name: 'SPRING_PROFILES_ACTIVE', value: 'prod' }
            { name: 'DB_HOST', value: postgres.properties.fullyQualifiedDomainName }
            { name: 'DB_PORT', value: '5432' }
            { name: 'DB_NAME', value: dbName }
            { name: 'DB_USERNAME', value: postgresAdminLogin }
            { name: 'DB_PASSWORD', secretRef: 'db-password' }
            { name: 'DB_SSLMODE', value: 'require' }
            { name: 'REDIS_HOST', value: redis.properties.hostName }
            { name: 'REDIS_PORT', value: '6380' }
            { name: 'REDIS_PASSWORD', secretRef: 'redis-password' }
            { name: 'REDIS_SSL_ENABLED', value: 'true' }
            { name: 'JWT_SECRET', secretRef: 'jwt-secret' }
            { name: 'OAUTH2_CLIENT_SECRET', secretRef: 'oauth2-client-secret' }
            { name: 'OAUTH2_ISSUER_URI', value: 'https://${appFqdn}' }
          ]
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/actuator/health'
                port: 8080
                scheme: 'HTTP'
              }
              initialDelaySeconds: 90
              periodSeconds: 30
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/actuator/health'
                port: 8080
                scheme: 'HTTP'
              }
              initialDelaySeconds: 60
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerApp.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrName string = acr.name
output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output postgresHost string = postgres.properties.fullyQualifiedDomainName
output redisHost string = redis.properties.hostName
output keyVaultName string = keyVault.name
output containerAppName string = containerApp.name
