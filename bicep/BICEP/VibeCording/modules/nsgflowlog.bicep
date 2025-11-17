param Location string
param NetworkWatcherName string
param NsgId string
param NsgName string
param StorageAccountId string
param LogAnalyticsWorkspaceId string
param Tags object

var FlowLogName = 'fl-${NsgName}'

resource networkWatcher 'Microsoft.Network/networkWatchers@2023-11-01' existing = {
  name: NetworkWatcherName
}

resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-11-01' = {
  parent: networkWatcher
  name: FlowLogName
  location: Location
  tags: Tags
  properties: {
    targetResourceId: NsgId
    storageId: StorageAccountId
    enabled: true
    retentionPolicy: {
      days: 90
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: LogAnalyticsWorkspaceId
        trafficAnalyticsInterval: 10
      }
    }
  }
}

output FlowLogId string = nsgFlowLog.id
