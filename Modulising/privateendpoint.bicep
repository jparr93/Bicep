param resourcename string
param location string = resourceGroup().location
param linkedresourceid string
param subnetid string
param privatednszoneid string
param zonegroupname string


resource pve 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: resourcename 
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: resourcename
        properties: {

    privateLinkServiceId: linkedresourceid
    groupIds:[
        'Blob'
    ]
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
    ]
    manualPrivateLinkServiceConnections: []
      subnet: {
        id: subnetid
      }
      customDnsConfigs: []

  }
}

resource prvdnszgroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: '${resourcename}/${zonegroupname}'
  dependsOn: [
    pve
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config01'
        properties: {
          privateDnsZoneId: privatednszoneid
        }
      }
    ]
  }
}

