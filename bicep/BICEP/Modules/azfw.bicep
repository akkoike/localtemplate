param location string
param hubVnetName string
param logAnalyticsWorkspaceName string

// Azure Firewall variables
var AZFW_NAME = 'azfw-poc-main-stag-001'
var AZFW_IF_NAME = 'azfwipconf-poc-main-stag-001'
var AZFW_PIP_NAME = 'azfwpip-poc-main-stag-001'
var AZFW_SKU = 'Standard'
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Reference the existing Log Analytics Workspace
resource existingloganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}
// Reference the existing HubVNET
resource existinghubvnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}

// Deploy public IP for Azure Firewall
resource azfwpip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: AZFW_PIP_NAME
  location: location
  tags: TAG_VALUE
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Deploy Azure Firewall
resource azfw 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: AZFW_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: AZFW_SKU
    }
  ipConfigurations: [
    {
      name: AZFW_IF_NAME
      properties: {
        subnet: {
          id: existinghubvnet.properties.subnets[0].id
        }
        publicIPAddress: {
          id: azfwpip.id
        }
      }
    }
  ]
  applicationRuleCollections: []
  networkRuleCollections: []
  natRuleCollections: []
  }
}

// Deploy diagnostic settings for Azure Firewall
resource azfwdignosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'azfwdignosticSettings'
  scope: azfw
  properties: {
    workspaceId: existingloganalyticsworkspace.id
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
        category: 'AZFWDNSProxy'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'AZFWPolicy'
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
