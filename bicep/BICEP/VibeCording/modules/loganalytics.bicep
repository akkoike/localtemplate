param Location string
param Environment string
param ProjectName string
param Tags object
param LogRetentionDays int

var WorkspaceName = 'law-${ProjectName}-${Environment}-${Location}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: WorkspaceName
  location: Location
  tags: Tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: LogRetentionDays
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

output WorkspaceId string = logAnalyticsWorkspace.id
output WorkspaceName string = logAnalyticsWorkspace.name
