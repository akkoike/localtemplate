param Location string
param VnetName string
param AddressPrefix string
param Subnets array
param Tags object
param LogAnalyticsWorkspaceId string = ''
param StorageAccountId string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: VnetName
  location: Location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        AddressPrefix
      ]
    }
    subnets: [for subnet in Subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: subnet.?networkSecurityGroupId != null ? {
          id: subnet.networkSecurityGroupId
        } : null
        routeTable: subnet.?routeTableId != null ? {
          id: subnet.routeTableId
        } : null
        privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies ?? 'Enabled'
      }
    }]
  }
}

resource vnetDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(LogAnalyticsWorkspaceId) && !empty(StorageAccountId)) {
  scope: virtualNetwork
  name: 'diag-${VnetName}'
  properties: {
    workspaceId: LogAnalyticsWorkspaceId
    storageAccountId: StorageAccountId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output VnetId string = virtualNetwork.id
output VnetName string = virtualNetwork.name
output SubnetIds array = [for (subnet, i) in Subnets: virtualNetwork.properties.subnets[i].id]
