param storageaccountname string
param globalRedundancy bool
param blobs array



resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name:  storageaccountname // must be globally unique' 
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for name in blobs: {
  name: '${sa.name}/default/${name}'
  // dependsOn will be added when the template is compiled
}]
