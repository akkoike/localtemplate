@allowed([
  'production'
  'staging'
])
param EnvironmentType string
param LocationName string = resourceGroup().location

var StorageAccountName = 'toy{uniqueString(resourceGroup().id)}'
var AppServiceName = 'topy-product-190'
var StorageAccountSkuName = (EnvironmentType == 'production') ? 'Standard_GRS' : 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: StorageAccountName
  location: LocationName
  sku: {
    name: StorageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: 'toy-product-launch-plan-starter'
  location: LocationName
  sku: {
    name: 'F1'
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: AppServiceName
  location: LocationName
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
