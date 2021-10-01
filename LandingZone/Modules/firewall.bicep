param fwpipname string
param fwpipresourcesku object
param fwpipresourceproperties object
param fwpipzones array
param resourcename string
param resourcetags object
param subnetid string
param resourcezones array
param resourcesku object
param threatintelmode string = 'alert'
param applicationrulecollections array
param natrulecollections array
param networkrulecollections array
param diagnosticworkspaceid string
param retentionpolicy object
param diagnosticsaid string

resource fwpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: fwpipname
  location: resourceGroup().location
  sku : fwpipresourcesku
  properties: fwpipresourceproperties
  zones: fwpipzones
}

resource azfw 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: resourcename
  location: resourceGroup().location
  tags: resourcetags
  zones: resourcezones
  properties: {
    additionalProperties: {}
    applicationRuleCollections: applicationrulecollections
    ipConfigurations: [
      {
        name: 'firewallconfig01'
        properties: {
          publicIPAddress: {
            id: fwpip.id
          }
          subnet: {
            id: subnetid
          }
        }
      }
    ]
    natRuleCollections: natrulecollections
    networkRuleCollections: networkrulecollections
    sku: resourcesku
    threatIntelMode: threatintelmode
  }
  
}

resource lawdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AZFW-Law-Diag'
  scope: azfw
  properties: {
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
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
  name: 'AZFW-sa-Diag'
  scope: azfw
  properties: {
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'AzureFirewallDnsProxy'
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
