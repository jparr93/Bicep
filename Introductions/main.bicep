param bicepparameters object
param globalRedundancy bool = true // defaults to true, but can be overridden
param currentYear string = utcNow('yyyy')

var storageaccountname = '${bicepparameters.storageaccount.prefix}${bicepparameters.storageaccount.name}${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = if(currentYear == '2021') {
  name:  storageaccountname // must be globally unique' 
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
}

output storageId string = sa.id
output storagename string = sa.name

// sa = symbolic name - identifier for referencing that resourcr

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for (name,index) in bicepparameters.blobs.names: {
  name: '${sa.name}/default/${name}-${index + 1}'
  // dependsOn will be added when the template is compiled
}]
