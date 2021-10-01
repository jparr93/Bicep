targetScope = 'subscription'

param resources object
param networking object
param storage object

module resourcenames './naming.module.bicep' = {
  scope: resourceGroup(resources.naming.rgname)
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

module law './loganalyticsworkspace.bicep' = {
  name: 'lawdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.logAnalyticsWorkspace.name
    resourceproperties: networking.loganalytics.properties
    resourcetags: networking.loganalytics.tags
  }
}

module vnet './virtualnetworks.bicep' = {
  name: 'vnetdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.virtualNetwork.name
    resourcetags: networking.virtualnetwork.virtualnetworktags
    subnets: networking.virtualnetwork.properties.subnets
    addressprefixes: networking.virtualnetwork.properties.addressspace.addressprefixes
    enableddosprotection: networking.virtualnetwork.properties.enableDdosProtection
    enablevmprotection: networking.virtualnetwork.properties.enableVmProtection
    diagnosticname: 'vnet-law-diag'
    diagnosticworkspaceid: law.outputs.lawid
  }
}

module stg './storageaccounts.bicep' = {
  name: 'storageDeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
  ]
  params: {
    resourcename: '${resourcenames.outputs.names.storageAccount.name}${uniqueString(deployment().name)}'
    globalRedundancy: storage.storageaccount.globalredundancy
    blobs: storage.blobs.names
  }
}

module pvlink './privatedns.bicep' = {
  name: 'pvlinkdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    stg
  ]
  params: {
    privatednszonenames: [
      'privatelink.blob.core.windows.net'
      'privatelink.file.core.windows.net'
    ]
    vnetlinkname: 'vnetpve'
    registrationenabled: false
    vnetid: vnet.outputs.vnetid
  }
}

module pve './privateendpoint.bicep' = {
  name: 'pvedeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    pvlink
    stg
  ]
  params: {
    resourcename: 'sapve1'
    linkedresourceid: stg.outputs.said
    subnetid: vnet.outputs.subnet1id
    zonegroupname: 'storage'
    privatednszoneid: '/subscriptions/3fcee2cc-1758-46d1-b7b7-d9d3f031c9b1/resourceGroups/rg1/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
  }
}

module azfw './firewall.bicep' = {
  name: 'fwdeploy'
  scope: resourceGroup(rg[0].name)
  dependsOn: [
    rg
    vnet
  ]
  params: {
    fwpipname: resourcenames.outputs.names.publicIp.name
    fwpipresourceproperties: networking.firewall.azfwpublicip.properties
    fwpipresourcesku: networking.firewall.azfwpublicip.sku
    fwpipzones: networking.firewall.azfwpublicip.zones
    subnetid: '${vnet.outputs.vnetid}/subnets/AzureFirewallSubnet'
    resourcename: resourcenames.outputs.names.firewall.name
    resourcesku: networking.firewall.properties.sku
    resourcetags: networking.firewall.properties.tags
    resourcezones: networking.firewall.properties.zones
    applicationrulecollections:networking.firewall.properties.rules.applicationrulcollections
    natrulecollections:networking.firewall.properties.rules.natrulecollections
    networkrulecollections:networking.firewall.properties.rules.networkrulecollections
    diagnosticsaid: stg.outputs.said
    diagnosticworkspaceid: law.outputs.lawid
    retentionpolicy: networking.firewall.properties.retentionpolicy
  }
}
