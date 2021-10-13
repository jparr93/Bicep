param resourcename string
param location string = resourceGroup().location
param resourcetags object
param accesspolicies array
param iprules array
param virtualnetworkrules array
param resourcesku object
param softdeleteretention int = 90
param tenantid string
param configureDiagnostics bool = true
param diagStorageAccountID string = ''
param logAnalyticsWorkspaceID string = ''


resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: resourcename
  location: location
  tags: resourcetags
  properties: {
    accessPolicies: accesspolicies
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: iprules
      virtualNetworkRules: virtualnetworkrules
    }
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'disabled'
    sku: resourcesku
    softDeleteRetentionInDays: softdeleteretention
    tenantId: tenantid
  }
}

resource saDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configureDiagnostics) && !empty(diagStorageAccountID)) {
  name: 'SA-Diag'
  scope: kv
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[
      {
        category: 'AuditEvent'
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
  scope: kv
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[
      {
        category: 'AuditEvent'
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

output keyvaultid string = kv.id
output keyvaultname string = kv.name
