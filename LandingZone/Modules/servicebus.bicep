param resourcename string
param location string = resourceGroup().location
param resourcetags object
param resourcesku object
param disablelocalauth bool = true
param identity object
param premiumnamespace bool = false
param premiumresourcecapacity int = 1
param keyvaultproperties array = []
param configureDiagnostics bool = true
param diagStorageAccountID string = ''
param logAnalyticsWorkspaceID string = ''


resource sb 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: resourcename
  location: location
  tags: resourcetags
  sku: premiumnamespace ? {
    capacity: premiumresourcecapacity
    name: 'Premium'
    tier: 'Premium'
  } : resourcesku
  identity: identity
  properties: {
    disableLocalAuth: disablelocalauth
    encryption: premiumnamespace ? {
      keySource: 'Microsoft.KeyVault'
      keyVaultProperties: keyvaultproperties
      requireInfrastructureEncryption: true
    } : json('null')
    privateEndpointConnections: []
    zoneRedundant: premiumnamespace
  }
}

resource saDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configureDiagnostics) && !empty(diagStorageAccountID)) {
  name: 'SA-Diag'
  scope: sb
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[
      {
        category: 'OperationalLogs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'VNetAndIPFilteringLogs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    metrics:[
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    storageAccountId: diagStorageAccountID
  }
}

resource laDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configureDiagnostics) && !empty(logAnalyticsWorkspaceID)) {
  name: 'LA-Diag'
  scope: sb
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[
      {
        category: 'OperationalLogs'
        enabled: true
        }
      {
        category: 'VNetAndIPFilteringLogs'
        enabled: true
        }
    ]
    metrics:[
      {
        category: 'AllMetrics'
        enabled: true
        }
    ]
    workspaceId: logAnalyticsWorkspaceID
  }
}

output servicebusid string = sb.id
output servicebusname string = sb.name
