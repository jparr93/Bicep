@minLength(3)
@maxLength(24)
param resourcename string
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param sku string = 'Standard_LRS'
@allowed([
  'Hot'
  'Cool'
])
param tier string = 'Hot'
param configureDiagnostics bool = true
param logAnalyticsWorkspaceID string = ''
param diagStorageAccountID string = ''
param blobs array = []
param fileShares array = []
param queues array = []
param tables array = []
param resourcetags object

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: resourcename // must be globally unique' 
  location: resourceGroup().location
  kind: 'StorageV2'
  tags: resourcetags
  sku: {
    name: sku
  }
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    encryption: {
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: tier
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for name in blobs:  {
  name: '${sa.name}/default/${name}'
  // dependsOn will be added when the template is compiled
}]

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = [for share in fileShares: {
  name: '${sa.name}/default/${share.name}'
  properties: {
    accessTier: share.accessTier
    shareQuota: share.shareQuota
  }
}]

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = [for queue in queues: {
  name: '${sa.name}/default/${queue}'
  properties: {
    metadata: {}
  }
}]

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-04-01' = [for table in tables: {
  name: '${sa.name}/default/${table}'
}]

resource stDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configureDiagnostics) && !empty(diagStorageAccountID)) {
  name: 'SA-Diag'
  scope: sa
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[]
    metrics:[
      {
        category: 'Transaction'
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
  scope: sa
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs:[]
    metrics:[
      {
        category: 'Transaction'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceID
  }
}

output accountid string = sa.id
output accountname string = sa.name
