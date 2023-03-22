param location string
// main.bicepから渡された変数名を宣言しておく
param appServiceAppName string
// main.bicepから渡された変数名を宣言しておく
@allowed([
  'staging'
  'production'
])
param environmentType string

var appServicePlanName = 'toy-product-launch-plan'
  // main.bicepから渡された変数名をここで使う
var appServicePlanSkuName = (environmentType == 'production') ? 'P2v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  // main.bicepから渡された変数名をここで使う
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
