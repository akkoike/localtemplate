param Location string
param IdentityName string
param Tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: IdentityName
  location: Location
  tags: Tags
}

output IdentityId string = managedIdentity.id
output PrincipalId string = managedIdentity.properties.principalId
output ClientId string = managedIdentity.properties.clientId
