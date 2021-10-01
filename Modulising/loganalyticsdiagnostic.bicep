param diagnosticname string
param vnetname string
param diagnosticworkspaceid string



resource lawdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticname
  scope: 'Microsoft.Network/VirtualNetworks/${vnetname}'
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
