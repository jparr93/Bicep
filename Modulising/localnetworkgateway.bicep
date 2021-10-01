param resourcename string
param resourcetags object
param resourceproperties object


resource lng 'Microsoft.Network/localNetworkGateways@2021-02-01' = {
  name: resourcename
  location: resourceGroup().location
  tags: resourcetags
  properties: resourceproperties
}
