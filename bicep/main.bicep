param location string = 'japaneast'
param storageAccountName string = 'akstr${uniqueString(resourceGroup().id)}'
param straccname string = 'akst2${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'akapp${uniqueString(resourceGroup().id)}'
@allowed([
  'staging'
  'production'
])
param environmentType string

var storageAccountSkuName = (environmentType == 'production') ? 'Standard_RAGRS' : 'Standard_LRS'



resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
// module名はhogehogeの変数名で適当に作成する
module hogehoge 'Modules/appService.bicep' = {
  name: 'appServiceModule1'
  params: {
    location: location
// paramで指定した変数と値をModule側のbicepへ受け渡す
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}
//ほげほげ名のモジュールから、変数名として戻り値を渡した appServiceAppHostName を受け取ってfugafugaにいれる。
//fugafugaの出力結果はportalのデプロイ結果の出力で表示される。
output fugafuga string = 'fugafuga-${hogehoge.outputs.appServiceAppHostName}'
//output appServiceAppHostName string = hogehoge.outputs.appServiceAppHostName
