param resourcename string
param resourcetags object
param subnets array
param addressprefixes array
param enablevmprotection bool
param enableddosprotection bool
param diagnosticname string
param diagnosticworkspaceid string

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
  name: diagnosticname
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

output vnetid string = vnet.id
output vnetname string = vnet.name
output subnetid string = '${vnet.id}/subnets/${subnets}'
output subnet1id string = reference(resourceId('Microsoft.Network/virtualNetworks', resourcename)).subnets[0].id
