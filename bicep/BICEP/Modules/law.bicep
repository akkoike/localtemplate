// Log Analytics WorkSpace
param location string
param amplsName string

// Log Analytics WorkSpace variables
var LAW_NAME = 'law-poc-main-stag-001'
var LAW_SKU = 'PerGB2018'
var LAW_RETANTION = 30
var LAW_SEARCH_VER = 2
var AMPLS_ASSOCIATION_NAME = 'amplsassociation-poc-main-stag-001'

// Tag Values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Reference to the Azure Monitor Private Link Scopes resource
resource existingampls 'Microsoft.Insights/privateLinkScopes@2021-07-01-preview' existing = {
  name: amplsName
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
    //publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: LAW_RETANTION
    features: {
      searchVersion: LAW_SEARCH_VER
    }
  }
}

// Deploy Azure Monitor Private Link Scopes association resource
resource amplsassociation 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: existingampls
  name: AMPLS_ASSOCIATION_NAME
  properties: {
    linkedResourceId: laws.id
  }
}

output OUTPUT_LAW_NAME string = laws.name
output OUTPUT_LAW_ID string = laws.id
