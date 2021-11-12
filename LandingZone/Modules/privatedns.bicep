param privatednszonenames array
param vnetlinkname string
param registrationenabled bool = false
param vnetid string
param resourcetags object

resource privdnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = [for name in privatednszonenames: {
  name: name
  location: 'Global'
  tags: resourcetags
  properties: {
  }
}]

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for name in privatednszonenames:{
  name: '${name}/${vnetlinkname}'
  location: 'Global'
  dependsOn: [
    privdnszone
  ]
  tags: resourcetags
  properties: {
    registrationEnabled: registrationenabled
    virtualNetwork: {
      id: vnetid
    }
  }
}]


output prvdnsdata array = [for i in range(0, length(privatednszonenames)): {
  name: privdnszone[i].name
  resourceid: privdnszone[i].id
}]
