targetScope = 'subscription'

param Environment string
param ProjectName string
param AllowedLocations array

var PolicyAssignmentName = 'policy-${ProjectName}-${Environment}'

resource allowedLocationsPolicy 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: '${PolicyAssignmentName}-locations'
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    displayName: 'Allowed locations for ${Environment}'
    parameters: {
      listOfAllowedLocations: {
        value: AllowedLocations
      }
    }
  }
}

resource enforcedTagPolicy 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: '${PolicyAssignmentName}-tags'
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62'
    displayName: 'Require a tag on resources for ${Environment}'
    parameters: {
      tagName: {
        value: 'env'
      }
    }
  }
}

output AllowedLocationsPolicyId string = allowedLocationsPolicy.id
output EnforcedTagPolicyId string = enforcedTagPolicy.id
