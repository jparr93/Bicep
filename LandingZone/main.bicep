targetScope = 'subscription'

param naming object
param resources object
param networking object
param diagnostics object

module resourcenames './modules/naming.module.bicep' = {
  scope: resourceGroup(resources.rg)
  name: 'NamingDeployment'
  params: {
    prefix: [
      naming.prefix1
      naming.prefix
    ]
    uniqueLength: 4
    uniqueSeed: subscription().id
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2019-10-01' = [for name in resources.resourcegroups: {
  name: name
  location: resources.location
  tags: resources.tags
}]

module law './modules/loganalyticsworkspace.bicep' = {
  name: 'lawdeploy'
  scope: resourceGroup('diag-rg')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.logAnalyticsWorkspace.name
    resourceproperties: diagnostics.loganalytics.properties
    resourcetags: resources.tags
  }
}

module stg './modules/storageaccounts.bicep' = {
  name: 'storageDeploy'
  scope: resourceGroup('diag-rg')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.storageAccount.name}${uniqueString(deployment().name)}'
    globalRedundancy: diagnostics.storageaccount.globalredundancy
    resourcetags: resources.tags
  }
}

module vnet './modules/virtualnetworks.bicep' = {
  name: 'vnetdeploy'
  scope: resourceGroup('hub-rg')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.virtualNetwork.name
    resourcetags: resources.tags
    subnets: networking.virtualnetwork.properties.subnets
    addressprefixes: networking.virtualnetwork.properties.addressspace.addressprefixes
    enableddosprotection: networking.virtualnetwork.properties.enableDdosProtection
    enablevmprotection: networking.virtualnetwork.properties.enableVmProtection
    diagnosticworkspaceid: law.outputs.lawid
    diagnosticsaid: stg.outputs.said
    retentionpolicy: diagnostics.retentionpolicy
  }
}

module fw './Modules/firewall.bicep' = {
  name: 'fwdeploy'
  scope: resourceGroup('hub-rg')
  params: {
    resourcepipname: '${resourcenames.outputs.names.publicIp.name}-fw'
    resourcepipproperties: networking.firewall.azfwpublicip.properties
    resourcepipsku: networking.firewall.azfwpublicip.sku
    subnetid: '${vnet.outputs.vnetid}/subnets/AzureFirewallSubnet'
    resourcename: resourcenames.outputs.names.firewall.name
    resourcesku: networking.firewall.properties.sku
    resourcetags: resources.tags
    resourcezones: networking.firewall.properties.zones
    applicationrulecollections: networking.firewall.properties.rules.applicationrulcollections
    natrulecollections: networking.firewall.properties.rules.natrulecollections
    networkrulecollections: networking.firewall.properties.rules.networkrulecollections
    storageaccountID: stg.outputs.said
    configurediagnostics: true
    retentionpolicy: diagnostics.retentionpolicy
  }
}

module lgw './modules/localnetworkgateway.bicep' = {
  name: 'localgatewaydeploy'
  scope: resourceGroup('hub-rg')
  dependsOn: [
    rg
    ]
    params: {
      resourcename: '${resourcenames.outputs.names.localNetworkGateway.name}-gw'
      resourceproperties: networking.localgateway.properties
      resourcetags: resources.tags
    }

}

module vng './modules/virtualnetworkgateway.bicep' = {
  name: 'vngdeploy'
  scope: resourceGroup('hub-rg')
  dependsOn: [
    rg
    vnet
  ]
  params: {
    resourcename: resourcenames.outputs.names.virtualNetworkGateway.name
    resourcetags: resources.tags
    activeactive: networking.gateway.activeactive
    enablebgp: networking.gateway.enablebgp
    enablednsforwarding: networking.gateway.enablednsforwarding
    enableprivateipaddress: networking.gateway.enableprivateipaddress
    privateipallocation: networking.gateway.privateipallocation
    vpntype: networking.gateway.vpntype
    resourcetype: networking.gateway.gatewaytype
    resourcepipsku: networking.gatewaypublicip.sku
    resourcepipname: '${resourcenames.outputs.names.publicIp.name}-gw'
    resourcepipproperties: networking.gatewaypublicip.properties
    resourcepipzones: networking.gatewaypublicip.zones
    resourcesku: networking.gateway.gatewaysku
    generation: networking.gateway.gatewaygeneration
    gatewayipconfigurationname: networking.gateway.gatewayipconfigurationname
    gatewaysubnetid: '${vnet.outputs.vnetid}/subnets/GatewaySubnet'
  }
}
