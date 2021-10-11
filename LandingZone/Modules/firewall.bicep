param resourcepipname string
param resourcepipsku object
param resourcepipproperties object
param resourcename string
param resourcetags object
param subnetid string
param resourcezones array
param resourcesku object
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatintelmode string = 'Alert'
param applicationrulecollections array
param natrulecollections array
param networkrulecollections array
param retentionpolicy object
param loganalyticsworkspaceID string = ''
param storageaccountID string =''
param location string = resourceGroup().location
param eventHubName string = ''
param eventHubAuthorizationRuleId string = ''
param configurediagnostics bool 

resource fwpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: resourcepipname
  location: location
  sku : resourcepipsku
  properties: resourcepipproperties
  zones: resourcezones
}

resource azfw 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: resourcename
  location: location
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

resource lawdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configurediagnostics) && !empty(loganalyticsworkspaceID)){
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
    workspaceId: loganalyticsworkspaceID
  }
}

resource sadiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configurediagnostics) && !empty(storageaccountID)) {
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
    storageAccountId: storageaccountID
  }
}

resource evntdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configurediagnostics) && !empty(eventHubName)){
  name: 'AZFW-EventHub-Diag'
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
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
  }
}
