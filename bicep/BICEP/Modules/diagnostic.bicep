// Diagnostic Settings
param appgwName string
param azfwName string
param bastionName string
param logAnalyticsWorkspaceName string
param amplsName string

// Diagnostic variables
var APPGW_DIAG_NAME = 'diag-poc-appgw-stag-001'
var AZFW_DIAG_NAME = 'diag-poc-azfw-stag-001'
var BASTION_DIAG_NAME = 'diag-poc-bastion-stag-001'
var AMPLS_DIAG_NAME = 'diag-poc-ampls-stag-001'

// Reference application gateway
resource existingappgw 'Microsoft.Network/applicationGateways@2020-06-01' existing = {
  name: appgwName
}
// Reference Azure Firewall
resource existingazfw 'Microsoft.Network/azureFirewalls@2020-06-01' existing = {
  name: azfwName
}
// Reference Azure Bastion
resource existingbastion 'Microsoft.Network/bastionHosts@2020-05-01' existing = {
  name: bastionName
}
// Reference Log Analytics Workspace
resource existinglaw 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsWorkspaceName
}
/*
// Reference Azure Monitor Private Link Scope
resource ampls 'Microsoft.Insights/privateLinkScopes@2020-10-01' existing = {
  name: amplsName
}

// Deploy diagnostic settings for application gateway
resource diagnosticappgw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: APPGW_DIAG_NAME
  scope: existingappgw
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Deploy diagnostic settings for Azure Firewall
resource dignosticSettingsazfw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: AZFW_DIAG_NAME
  scope: existingazfw
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'AZFWApplicationRule'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'AZFWNetworkRule'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'AZFWNatRule'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Deploy diagnostic settings for Azure Bastion

// Deploy diagnostic settings for Azure Monitor Private Link Scope
