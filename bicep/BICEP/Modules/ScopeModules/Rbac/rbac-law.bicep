// RBAC for Log Analytics Workspace
param lawName string

// User variables
var USER_OBJECT_ID = loadJsonContent('./law-user.json', 'UserObjectId001')

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

// Reference Log Analytics Workspace
resource law 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: lawName
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
