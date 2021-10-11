param resourcename string
param location string = resourceGroup().location
param linkedresourceid string
param subnetid string
param groupIds array


resource pve 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: resourcename 
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: resourcename
        properties: {

    privateLinkServiceId: linkedresourceid
    groupIds:groupIds
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

output endpointname string = pve.name
output endpointid string = pve.id


