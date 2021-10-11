targetScope = 'subscription'

param naming object
param resources object
param networking object
param diagnostics object

module resourcenames './modules/naming.module.bicep' = {
  scope: resourceGroup('NetworkWatcherRG')
  name: 'NamingDeployment'
  params: {
    prefix: [
      naming.prefix1
      naming.prefix
    ]
    uniqueLength: 4
    uniqueSeed: subscription().id
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2019-10-01' = [for name in resources.resourcegroups: {
  name: name
  location: resources.location
  tags: resources.tags
}]

module law './modules/loganalyticsworkspace.bicep' = {
  name: 'lawdeploy'
  scope: resourceGroup('diag-rg')
  dependsOn: [
    rg
  ]
  params: {
    resourcename: resourcenames.outputs.names.logAnalyticsWorkspace.name
    resourceproperties: diagnostics.loganalytics.properties
    resourcetags: resources.tags
  }
}

