// Log Analytics WorkSpace
param location string

// Log Analytics WorkSpace variables
var LAW_NAME = 'law-poc-main-stag-001'
var LAW_SKU = 'PerGB2018'
var LAW_RETANTION = 30
var LAW_SEARCH_VER = 2

// Tag Values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Deploy Log Analytics Workspace
resource laws 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: LAW_NAME
  location: location
  tags: TAG_VALUE
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
output OUTPUT_LAW_NAME string = LAW_NAME
