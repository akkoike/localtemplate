// Log Analytics Workspace module
param Location string
param WorkspaceName string
param RetentionInDays int = 90
param Tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: WorkspaceName
  location: Location
  tags: Tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: RetentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output WorkspaceId string = logAnalyticsWorkspace.id
output WorkspaceName string = logAnalyticsWorkspace.name
output WorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
