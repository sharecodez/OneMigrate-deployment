@description('Name of the Web App to deploy.')
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Location for resources.')
param location string = resourceGroup().location

@description('The App Service pricing tier.')
@allowed([
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
])
param sku string = 'B1'

@description('The Virtual Network to use for the Web App.')
param selectedVnet string

@description('The Subnet to use within the selected VNet.')
param selectedSubnet string

var appServicePlanName = 'AppServicePlan-${webAppName}'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      virtualNetworkSubnetId: subscriptionResourceId('Microsoft.Network/virtualNetworks/subnets', selectedVnet, selectedSubnet)
    }
  }
}

output availableVNets array = [for vnet in listResourceGroupResources('Microsoft.Network/virtualNetworks') : {
  name: vnet.name
  id: vnet.id
  subnets: vnet.properties.subnets
}]
