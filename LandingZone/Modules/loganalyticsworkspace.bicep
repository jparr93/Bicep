param resourcename string
param resourcetags object
param location string = resourceGroup().location
param resourceproperties object

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: resourcename
  location: location
  tags: resourcetags 
  properties: resourceproperties
}


output workspaceid string = law.id
output workspacename string = law.name
