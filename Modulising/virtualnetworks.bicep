param virtualnetworkname string
param virtualnetworktags object
param addressprefix array
param enablevmprotection bool
param enableddos bool
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2018-10-01' = {
  name: virtualnetworkname
  location: resourceGroup().location
  tags: virtualnetworktags
  
  properties: {
    addressSpace: {
      addressPrefixes: addressprefix
    }
    enableVmProtection: enablevmprotection
    enableDdosProtection: enableddos
    subnets: subnets
  }
}

output vnetid string = vnet.id
output vnetname string = vnet.name
