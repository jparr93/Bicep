param bicepparameters object

var storageaccountname = '${bicepparameters.storageaccount.prefix}${bicepparameters.storageaccount.name}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageaccountname
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${stg.name}/default/logs'
  // dependsOn will be added when the template is compiled
}

output storageId string = stg.id // replacement for resourceId(...)
output primaryEndpoint string = stg.properties.primaryEndpoints.blob // replacement for reference(...).*
