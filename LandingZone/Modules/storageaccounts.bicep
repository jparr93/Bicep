param resourcename string
param globalRedundancy bool
param resourcetags object
//param blobs array

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: resourcename // must be globally unique' 
  location: resourceGroup().location
  kind: 'StorageV2'
  tags: resourcetags
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
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
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

output said string = sa.id

//resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for name in blobs: {
  //name: '${sa.name}/default/${name}'
  // dependsOn will be added when the template is compiled
//}]
