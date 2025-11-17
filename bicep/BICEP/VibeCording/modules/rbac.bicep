param PrincipalId string

var ContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, PrincipalId, ContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: ContributorRoleDefinitionId
    principalId: PrincipalId
    principalType: 'ServicePrincipal'
  }
}

output RoleAssignmentId string = roleAssignment.id
