targetScope = 'subscription'

param resources object
param storage object
param networking object
param naming object
param loganalytics object

module resourcenames './naming.module.bicep' = {
  scope: resourceGroup(naming.rgname)
  name: 'NamingDeployment'
  params: {
    prefix: [
      resources.naming.prefix
    ]
    suffix: [
      resources.naming.suffix
    ]
    uniqueLength: 4
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2019-10-01' = [for name in resources.resourcegroupnames: {
  name: name
  location: resources.location
}]

module stg './storageaccounts.bicep' = {
  name: 'storageDeploy'
  scope: resourceGroup('rg1')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.storageAccount.name}${uniqueString(deployment().name)}'
    globalRedundancy: storage.storageaccount.globalredundancy
    blobs: storage.blobs.names
  }
}

module vnet './virtualnetworks.bicep' = {
  name: 'vnetdeploy'
  scope: resourceGroup('rg2')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.virtualNetwork.name
    resourcetags: networking.virtualnetwork.virtualnetworktags
    resourceproperties: networking.virtualnetwork.properties
  }
}

module gwpip './publicipaddress.bicep' = {
  name: 'gwpipdeploy'
  scope: resourceGroup('rg2')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.publicIp.name
    resourceproperties: networking.gatewaypublicip.properties
    resourcesku: networking.gatewaypublicip.sku
    zones: networking.gatewaypublicip.zones
  }
}
module lgw './localnetworkgateway.bicep' = {
  name: 'localgatewaydeploy'
  scope: resourceGroup('rg2')
  dependsOn: [
    rg
    ]
    params: {
      resourcename: resourcenames.outputs.names.localNetworkGateway.name
      resourceproperties: networking.localgateway.properties
      resourcetags: networking.localgateway.tags
    }

}

module law './loganalyticsworkspace.bicep' = {
  name: 'lawdeploy'
  scope: resourceGroup('rg1')
  dependsOn: [
    rg
  ]
  params:{
    resourcename: resourcenames.outputs.names.logAnalyticsWorkspace.name
    resourceproperties: loganalytics.properties
    resourcetags: loganalytics.tags
  }
}

module vng './virtualnetworkgateway.bicep' = {
  name: 'vngdeploy'
  scope: resourceGroup('rg2')
  dependsOn: [
    rg
    gwpip
  ]
  params: {
    virtualgatewayname: resourcenames.outputs.names.virtualNetworkGateway.name
    virtualgatewaytags: networking.gateway.tags
    activeactive: networking.gateway.activeactive
    enablebgp: networking.gateway.enablebgp
    enablednsforwarding: networking.gateway.enablednsforwarding
    enableprivateipaddress: networking.gateway.enableprivateipaddress
    privateipallocation: networking.gateway.privateipallocation
    gatewayvpntype: networking.gateway.vpntype
    gatewaytype: networking.gateway.gatewaytype
    gatewaysku: networking.gateway.gatewaysku
    gatewaygeneration: networking.gateway.gatewaygeneration
    gatewayipconfigurationname: networking.gateway.gatewayipconfigurationname
    gatewaysubnetid: '${vnet.outputs.vnetid}/subnets/GatewaySubnet'
    gatewaypipid: gwpip.outputs.pipid
  }
}


resource diag 'Microsoft.Insights/diagnosticSettings@'
