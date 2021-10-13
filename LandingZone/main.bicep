targetScope = 'subscription'

param naming object
param resources object
param networking object
param diagnostics object

module resourcenames './modules/naming.module.bicep' = {
  scope: resourceGroup('NetworkWatcherRG')
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
    resourcetags: resources.tags
  }
}

module vnet './modules/virtualnetworks.bicep' = [for i in range(0, 4): {
  name: 'vnetdeploy${i}'
  scope: resourceGroup('hub-rg')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.virtualNetwork.name}${i}'
    resourcetags: resources.tags
    subnets: networking.virtualnetwork.properties.subnets
    addressprefixes: networking.virtualnetwork.properties.addressspace.addressprefixes
    enableddosprotection: networking.virtualnetwork.properties.enableDdosProtection
    enablevmprotection: networking.virtualnetwork.properties.enableVmProtection
    diagnosticworkspaceid: law.outputs.workspaceid
    diagnosticsaid: stg.outputs.accountid
    retentionpolicy: diagnostics.retentionpolicy
  }
}]

module pvlink './Modules/privatedns.bicep' = {
  name: 'pvlinkdeploy'
  scope: resourceGroup('hub-rg')
  dependsOn: [
    rg
    stg
    vnet
  ]
  params: {
    privatednszonenames: networking.privateendpoints.privatednszonenames
    vnetlinkname: 'vnetpve'
    registrationenabled: false
    vnetid: vnet[0].outputs.vnetid
    resourcetags: resources.tags
  }
}

module pve './modules/privateendpoint.bicep' = {
  name: 'pvedeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    pvlink
    stg
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.storageAccount.name}${uniqueString(deployment().name)}'
    linkedresourceid: stg.outputs.accountid
    subnetid: vnet[0].outputs.subnetids[0].resourceid
    groupIds: [
      'Blob'
    ]
  }
}

module pvednszonegroup './Modules/privatednszonegroup.bicep' = {
  name: 'zonegroupdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    pvlink
    stg
    pve
  ]
  params: {
    privatednszoneid: pvlink.outputs.prvdnsdata[0].resourceid
    zonegroupname: 'storage'
    privateEndpointname: pve.outputs.endpointname
  }
}

module servicebus './Modules/servicebus.bicep' = {
  name: 'sbdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    pvlink
    stg
    pve
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.serviceBusNamespace.name}${uniqueString(deployment().name)}-5'
    resourcesku: networking.servicebus.resourcesku
    resourcetags: resources.tags
    premiumnamespace: false
    identity: networking.servicebus.identity
    logAnalyticsWorkspaceID: law.outputs.workspaceid
  }
}

module keyvault './Modules/keyvault.bicep' = {
  name: 'kvdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    pvlink
    stg
    pve
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.keyVault.name}${uniqueString(deployment().name)}'
    resourcesku: networking.keyvault.resourcesku
    resourcetags: resources.tags
    logAnalyticsWorkspaceID: law.outputs.workspaceid
    accesspolicies: networking.keyvault.accesspolicies
    iprules: networking.keyvault.iprules
    virtualnetworkrules: networking.keyvault.virtualnetworkrules
    tenantid: networking.keyvault.tenantid
  }
}
