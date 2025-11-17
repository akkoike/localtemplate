param PrivateLinkScopeName string
param Location string
param Tags object

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: PrivateLinkScopeName
  location: Location
  tags: Tags
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'PrivateOnly'
    }
  }
}

output PrivateLinkScopeId string = privateLinkScope.id
output PrivateLinkScopeName string = privateLinkScope.name
