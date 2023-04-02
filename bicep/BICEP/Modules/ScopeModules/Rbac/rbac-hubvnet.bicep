// RBAC for Hub vNET
param hubVnetName string

// User variables
var USER_OBJECT_ID = loadJsonContent('./hubvnet-user.json', 'UserObjectId001')

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

// Reference hub virtual network
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
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
