param virtualgatewayname string
param virtualgatewaytags object
param activeactive bool
param enablebgp bool
param enablednsforwarding bool
param enableprivateipaddress bool
param gatewaytype string
param gatewaysku object
param gatewaygeneration string
param gatewayipconfigurationname string
param privateipallocation string
param gatewaysubnetid string
param gatewayvpntype string
param gatewaypipid string



resource vng 'Microsoft.Network/virtualNetworkGateways@2020-03-01' = {
  name: virtualgatewayname
  location: resourceGroup().location
  tags: virtualgatewaytags
  properties: {
    activeActive: activeactive
    enableBgp: enablebgp
    enableDnsForwarding: enablednsforwarding
    enablePrivateIpAddress: enableprivateipaddress
    gatewayType: gatewaytype
    ipConfigurations: [{
      name: gatewayipconfigurationname
      properties: {
        privateIPAllocationMethod: privateipallocation
        publicIPAddress: {
          id: gatewaypipid
        }
        subnet: {
          id: gatewaysubnetid
        }
      }
    }
  ]
    sku: gatewaysku
    vpnType: gatewayvpntype
    vpnGatewayGeneration: gatewaygeneration
  }
}

