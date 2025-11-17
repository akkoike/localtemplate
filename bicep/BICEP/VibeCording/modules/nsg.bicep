param Location string
param NsgName string
param SecurityRules array
param Tags object
param LogAnalyticsWorkspaceId string = ''
param StorageAccountId string = ''

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: NsgName
  location: Location
  tags: Tags
  properties: {
    securityRules: SecurityRules
  }
}

resource nsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(LogAnalyticsWorkspaceId) && !empty(StorageAccountId)) {
  scope: networkSecurityGroup
  name: 'diag-${NsgName}'
  properties: {
    workspaceId: LogAnalyticsWorkspaceId
    storageAccountId: StorageAccountId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

output NsgId string = networkSecurityGroup.id
output NsgName string = networkSecurityGroup.name
