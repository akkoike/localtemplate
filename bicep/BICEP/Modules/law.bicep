param location string

var LAW_NAME = 'law-poc-main-stag-001'
var LAW_SKU = 'PerGB2018'
var LAW_RETANTION = 30
var LAW_SEARCH_VER = 2

// Deploy Log Analytics Workspace
resource laws 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: LAW_NAME
  location: location
  properties: {
    sku: {
      name: LAW_SKU
    }
    retentionInDays: LAW_RETANTION
    features: {
      searchVersion: LAW_SEARCH_VER
    }
  }
}
output OUTPUT_LAW_NAME string = laws.name
