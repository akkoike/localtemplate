// Log Analytics WorkSpace
param location string
param principalId string
//param managedIdentityId string

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

// RBAC Configuration
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  //scope: subscription()
  // Owner
  //name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  // Contributer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // Reader
  //name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// RBAC assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(laws.id, principalId, contributorRoleDefinition.id)
  scope: laws
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
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
