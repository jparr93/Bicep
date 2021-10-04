param resourcename string
param resourcetags object
param subnets array
param addressprefixes array
param enablevmprotection bool = true
param enableddosprotection bool
param diagnosticworkspaceid string
param retentionpolicy object
param diagnosticsaid string

resource vnet 'Microsoft.Network/virtualNetworks@2018-10-01' = {
  name: resourcename
  location: resourceGroup().location
  tags: resourcetags

  properties: {
    addressSpace: {
      addressPrefixes: addressprefixes
    }
    enableVmProtection: enablevmprotection
    enableDdosProtection: enableddosprotection
    subnets: subnets
  }
}

resource lawdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vnet-law-diag'
  scope: vnet
  properties: {
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: diagnosticworkspaceid
  }
}

resource sadiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vnet-sa-Diag'
  scope: vnet
  properties: {
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
        retentionPolicy: retentionpolicy
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: retentionpolicy
      }
    ]
    storageAccountId: diagnosticsaid
  }
}


output vnetid string = vnet.id
output vnetname string = vnet.name
output subnetid string = '${vnet.id}/subnets/${subnets}'
output subnet1id string = reference(resourceId('Microsoft.Network/virtualNetworks', resourcename)).subnets[0].id
