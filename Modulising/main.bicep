param bicepparameters object
param networking object
param naming object


module resourcenames './naming.module.bicep' = {
  scope: resourceGroup(naming.rgname)
  name: 'NamingDeployment'  
  params: {
    prefix:[
      naming.prefix
    ]
    suffix: [
      naming.suffix
    ]
    uniqueLength: 4
  }
}


module stg './storageaccounts.bicep' = {
  name: 'storageDeploy'
  params: {
    storageaccountname: '${resourcenames.outputs.names.storageAccount.name}${uniqueString(resourceGroup().id)}'
    globalRedundancy: bicepparameters.storageaccount.globalredundancy
    blobs: bicepparameters.blobs.names
  }
}

module vnet './virtualnetworks.bicep' = {
  name: 'vnetdeploy'
  params: {
    virtualnetworkname: resourcenames.outputs.names.virtualNetwork.name
    virtualnetworktags: networking.virtualnetwork.virtualnetworktags
    addressprefix: networking.virtualnetwork.addressprefix
    enableddos: networking.virtualnetwork.enableddos
    enablevmprotection: networking.virtualnetwork.enablevmprotection
    subnets: networking.virtualnetwork.subnets
  }
}
