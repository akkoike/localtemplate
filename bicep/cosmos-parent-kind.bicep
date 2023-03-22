param cosmosDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param cosmosDBDatabaseThroughput int = 400
var cosmosDBDatabaseName = 'FlightTests'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
// ここで親であるcosmosDBAccountを認識させるために指定させる（依存関係）
  parent: cosmosDBAccount
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }
}
