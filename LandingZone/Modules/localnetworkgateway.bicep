param resourcename string
param resourcetags object
param resourceproperties object
param location string = resourceGroup().location

resource lng 'Microsoft.Network/localNetworkGateways@2021-02-01' = {
  name: resourcename
  location: location
  tags: resourcetags
  properties: resourceproperties
}
