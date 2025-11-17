param Location string
param FirewallName string
param SubnetId string
param Tags object
param LogAnalyticsWorkspaceId string

var PublicIpName = 'pip-${FirewallName}'

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

resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: FirewallName
  location: Location
  tags: Tags
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
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
    networkRuleCollections: [
      {
        name: 'AllowAzureServices'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowAzureOutbound'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                '192.168.0.0/16'
                '172.16.0.0/16'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '443'
                '80'
              ]
            }
          ]
        }
      }
    ]
  }
}

resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureFirewall
  name: 'diag-${FirewallName}'
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

output FirewallId string = azureFirewall.id
output FirewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
