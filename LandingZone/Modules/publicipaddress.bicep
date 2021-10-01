param resourcename string
param resourcesku object
param resourceproperties object
param zones array


resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: resourcename
  location: resourceGroup().location
  sku : resourcesku
  properties: resourceproperties
  zones: zones
}

output pipid string = pip.id
