param privatednszoneid string
param zonegroupname string
param privateEndpointname string

resource prvdnszonegroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: '${privateEndpointname}/${zonegroupname}'
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
