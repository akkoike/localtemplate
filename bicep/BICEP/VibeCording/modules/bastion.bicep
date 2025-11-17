param Location string
param BastionName string
param SubnetId string
param Tags object
param LogAnalyticsWorkspaceId string

var PublicIpName = 'pip-${BastionName}'

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: PublicIpName
  location: Location
  tags: Tags
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: BastionName
  location: Location
  tags: Tags
  sku: {
    name: 'Standard'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: SubnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

resource bastionDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastionHost
  name: 'diag-${BastionName}'
  properties: {
    workspaceId: LogAnalyticsWorkspaceId
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

output BastionId string = bastionHost.id
