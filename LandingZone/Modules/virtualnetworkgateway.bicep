param resourcepipname string
param resourcepipsku object
param resourcepipproperties object
param resourcepipzones array
param resourcename string
param resourcetags object
param location string = resourceGroup().location
param activeactive bool
param enablebgp bool
param enablednsforwarding bool
param enableprivateipaddress bool
param resourcetype string
param resourcesku object
param generation string
param gatewayipconfigurationname string
param privateipallocation string
param gatewaysubnetid string
param vpntype string
param configurediagnostics bool
param loganalyticsworkspaceID string = ''
param storageaccountID string = ''
param eventHubName string = ''
param eventHubAuthorizationRuleId string
param retentionpolicy string

resource gwpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: resourcepipname
  location: resourceGroup().location
  sku: resourcepipsku
  properties: resourcepipproperties
  zones: resourcepipzones
}

resource vng 'Microsoft.Network/virtualNetworkGateways@2020-03-01' = {
  name: resourcename
  location: location
  tags: resourcetags
  properties: {
    activeActive: activeactive
    enableBgp: enablebgp
    enableDnsForwarding: enablednsforwarding
    enablePrivateIpAddress: enableprivateipaddress
    gatewayType: resourcetype
    ipConfigurations: [
      {
        name: gatewayipconfigurationname
        properties: {
          privateIPAllocationMethod: privateipallocation
          publicIPAddress: {
            id: gwpip.id
          }
          subnet: {
            id: gatewaysubnetid
          }
        }
      }
    ]
    sku: resourcesku
    vpnType: vpntype
    vpnGatewayGeneration: generation
  }
}

resource lawdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configurediagnostics) && !empty(loganalyticsworkspaceID)) {
  name: 'VNG-Law-Diag'
  scope: vng
  properties: {
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
      }
      {
        category: 'RouteDiagnosticLog'
        enabled: true
      }
      {
        category: 'IKEDiagnosticLog'
        enabled: true
      }
      {
        category: 'P2SDiagnosticLog'
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
  name: 'VNG-sa-Diag'
  scope: vng
  properties: {
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'RouteDiagnosticLog'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'IKEDiagnosticLog'
        enabled: true
        retentionPolicy: retentionpolicy
      }
      {
        category: 'P2SDiagnosticLog'
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

resource evntdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((configurediagnostics) && !empty(eventHubName)) {
  name: 'VNG-EventHub-Diag'
  scope: vng
  properties: {
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
      }
      {
        category: 'RouteDiagnosticLog'
        enabled: true
      }
      {
        category: 'IKEDiagnosticLog'
        enabled: true
      }
      {
        category: 'P2SDiagnosticLog'
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
