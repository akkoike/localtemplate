param appgwName string
param azfwName string
param bastionName string
param lawName string
param hubVnetName string
param spokeVnetName string
//param amplsName string

var USER_OBJECT_ID = loadJsonContent('./userparam.json', 'UserObjectId001')

// Deploy Managed IDentity (User Assigned) if needed
/*
param managedIdentityName string = 'MyUserManagedIdentity'
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}
*/

// RBAC Configuration ( default to Contributor role)
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
resource ownerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  // Owner
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}
resource readerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  // Reader
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// Reference application gateway
resource appgw 'Microsoft.Network/applicationGateways@2020-06-01' existing = {
  name: appgwName
}
// Reference Azure Firewall
resource azfw 'Microsoft.Network/azureFirewalls@2020-06-01' existing = {
  name: azfwName
}
// Reference Azure Bastion
resource bastion 'Microsoft.Network/bastionHosts@2020-05-01' existing = {
  name: bastionName
}
// Reference Log Analytics Workspace
resource law 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: lawName
}
// Reference hub virtual network
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}
// Reference spoke virtual network
resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: spokeVnetName
}
// Reference Azure Monitor Private Link Scope
resource ampls 'Microsoft.Insights/privateLinkScopes@2020-10-01' existing = {
  name: amplsName
}

// RBAC assignment for application gateway
resource roleAssignmentappgw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appgw.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: appgw
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Firewall
resource roleAssignmentazfw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azfw.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: azfw
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Bastion
resource roleAssignmentbastion 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(bastion.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: bastion
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Log Analytics Workspace
resource roleAssignmentlaw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(law.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: law
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for hub virtual network
resource roleAssignmenthubvnet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(hubVnet.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: hubVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for spoke virtual network
resource roleAssignmentspokevnet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(spokeVnet.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: spokeVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Monitor Private Link Scope
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(ampls.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: ampls
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
