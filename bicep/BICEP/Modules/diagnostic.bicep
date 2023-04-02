// Diagnostic Settings
param appgwName string
param azfwName string
param bastionName string
param logAnalyticsWorkspaceName string
param pipappgwName string
param pipbastionName string
param pipazfwName string
param nsgappgwwafName string
param nsgdnsName string
param nsgspokeName string
param straccNsgFlowLogName string

// Diagnostic variables
var APPGW_DIAG_NAME = 'diag-poc-appgw-stag-001'
var AZFW_DIAG_NAME = 'diag-poc-azfw-stag-001'
var BASTION_DIAG_NAME = 'diag-poc-bastion-stag-001'
var PIP_APPGW_DIAG_NAME = 'diag-poc-pipappgw-stag-001'
var PIP_BASTION_DIAG_NAME = 'diag-poc-pipbastion-stag-001'
var PIP_AZFW_DIAG_NAME = 'diag-poc-pipazfw-stag-001'
var NSG_APPGW_WAF_DIAG_NAME = 'diag-poc-nsgappgwwaf-stag-001'
var NSG_DNS_DIAG_NAME = 'diag-poc-nsgdns-stag-001'
var NSG_SPOKE_DIAG_NAME = 'diag-poc-nsgspoke-stag-001'
var STR_ACC_NSG_FLOW_LOG_DIAG_NAME = 'diag-poc-straccnsgflowlog-stag-001'

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
// Reference Public IP Address for Application Gateway
resource existingpipappgw 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  name: pipappgwName
}
// Reference Public IP Address for Azure Bastion
resource existingpipbastion 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  name: pipbastionName
}
// Reference Public IP Address for Azure Firewall
resource existingpipazfw 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  name: pipazfwName
}
// Reference Network Security Group for Application Gateway WAF
resource existingnsgappgwwaf 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: nsgappgwwafName
}
// Reference Network Security Group for DNS
resource existingnsgdns 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: nsgdnsName
}
// Reference Network Security Group for Spoke
resource existingnsgspoke 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: nsgspokeName
}
// Reference Storage Account for Network Security Group Flow Logs
resource existingstraccnsgflowlog 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: straccNsgFlowLogName
    resource existingstraccnsgflowlogblob 'blobServices' existing = {
      name: 'default'
    }
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
resource diagnosticbastion 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: BASTION_DIAG_NAME
  scope: existingbastion
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'BastionAuditLogs'
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

// Deploy diagnostic settings for public IP address of application gateway
resource diagnosticpipappgw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: PIP_APPGW_DIAG_NAME
  scope: existingpipappgw
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationReports'
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
// Deploy diagnostic settings for public IP address of Azure Bastion
resource diagnosticpipbastion 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: PIP_BASTION_DIAG_NAME
  scope: existingpipbastion
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationReports'
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
// Deploy diagnostic settings for public IP address of Azure Firewall
resource diagnosticpipazfw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: PIP_AZFW_DIAG_NAME
  scope: existingpipazfw
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DDoSMitigationReports'
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
// Deploy diagnostic settings for Network Security Group of Application Gateway WAF
resource diagnosticnsgappgwwaf 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: NSG_APPGW_WAF_DIAG_NAME
  scope: existingnsgappgwwaf
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
// Deploy diagnostic settings for Network Security Group of dns
resource diagnosticnsgdns 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: NSG_DNS_DIAG_NAME
  scope: existingnsgdns
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
// Deploy diagnostic settings for Network Security Group of spoke
resource diagnosticnsgspoke 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: NSG_SPOKE_DIAG_NAME
  scope: existingnsgspoke
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
// Deploy diagnostic settings for Storage Account of NSG Flow Logs
resource diagnosticstorageaccountnsgflowlogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: STR_ACC_NSG_FLOW_LOG_DIAG_NAME
  scope: existingstraccnsgflowlog::existingstraccnsgflowlogblob
  properties: {
    workspaceId: existinglaw.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
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
