// NSG Flow Logs
param location string
param nsgappgwwafName string
param nsgdnsName string
param nsgspokeName string
param currentResourceGroupName string
param straccId string
param lawId string

// NSG Flow Logs variables
var NSG_FLOWLOGS_APPGWWAF_NAME = 'nsgflowappgwwaf-poc-main-stag-001'
var NSG_FLOWLOGS_DNS_NAME = 'nsgflowdns-poc-main-stag-001'
var NSG_FLOWLOGS_SPOKE_NAME = 'nsgflowspoke-poc-main-stag-001'

// Reference to the existing NSG for the App GW WAF
resource existingnsgappgwwaf 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  scope: resourceGroup(currentResourceGroupName)
  name: nsgappgwwafName
}
// Reference to the existing NSG for the DNS
resource existingnsgdns 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  scope: resourceGroup(currentResourceGroupName)
  name: nsgdnsName
}
// Reference to the existing NSG for the Spoke
resource existingnsgspoke 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  scope: resourceGroup(currentResourceGroupName)
  name: nsgspokeName
}

// Deploy the NSG Flow Logs for the App GW WAF
resource nsgflowlogsappgwwaf 'Microsoft.Network/networkWatchers/flowLogs@2022-09-01' = {
  name: 'NetworkWatcher_${location}/${NSG_FLOWLOGS_APPGWWAF_NAME}'
  location: location
  properties: {
    targetResourceId: existingnsgappgwwaf.id
    storageId: straccId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: lawId
        trafficAnalyticsInterval: 10
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
}
// Deploy the NSG Flow Logs for the DNS
resource nsgflowlogsdns 'Microsoft.Network/networkWatchers/flowLogs@2022-09-01' = {
  name: 'NetworkWatcher_${location}/${NSG_FLOWLOGS_DNS_NAME}'
  location: location
  properties: {
    targetResourceId: existingnsgdns.id
    storageId: straccId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: lawId
        trafficAnalyticsInterval: 10
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
}
// Deploy the NSG Flow Logs for the Spoke
resource nsgflowlogsspoke 'Microsoft.Network/networkWatchers/flowLogs@2022-09-01' = {
  name: 'NetworkWatcher_${location}/${NSG_FLOWLOGS_SPOKE_NAME}'
  location: location
  properties: {
    targetResourceId: existingnsgspoke.id
    storageId: straccId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: lawId
        trafficAnalyticsInterval: 10
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
}
