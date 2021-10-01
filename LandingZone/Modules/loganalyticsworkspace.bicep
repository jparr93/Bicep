param resourcename string
param resourcetags object
param resourceproperties object

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: resourcename
  location: resourceGroup().location
  tags: resourcetags 

  properties: resourceproperties
}

output lawid string = law.id
