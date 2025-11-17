param PrivateLinkScopeName string
param ScopedResourceName string
param LinkedResourceId string

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' existing = {
  name: PrivateLinkScopeName
}

resource scopedResource 'microsoft.insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: privateLinkScope
  name: ScopedResourceName
  properties: {
    linkedResourceId: LinkedResourceId
  }
}

output ScopedResourceId string = scopedResource.id
