param location string
param logAnalyticsWorkspaceName string

// Hub vNET/Subnet valiables
var VNET_HUB_NAME = 'vnet-poc-hub-stag-001'
var VNET_HUB_ADDRESS_SPACE = '192.168.0.0/16'
var VNET_HUB_TO_SPOKE_PEERING = 'vnetpeering-poc-hub2spoke-001'
var VNET_SPOKE_TO_HUB_PEERING = 'vnetpeering-poc-spoke2hub-001'
var AZFW_HUB_SUBNET_NAME = 'AzureFirewallSubnet'
var AZFW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.0.0/26'
var BASTION_HUB_SUBNET_NAME = 'AzureBastionSubnet'
var BASTION_HUB_SUBNET_ADDRESS_PREFIX = '192.168.1.0/26'
var GW_HUB_SUBNET_NAME = 'GatewaySubnet'
var GW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.2.0/27'
var APPGW_HUB_SUBNET_NAME = 'AppGwSubnet'
var APPGW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.3.0/27'

// Spoke vNET valiables
var VNET_SPOKE_NAME = 'vnet-poc-spoke-stag-001'
var VNET_SPOKE_ADDRESS_SPACE = '172.16.0.0/16'
var VM_SPOKE_SUBNET_NAME = 'VmSubnet'
var VM_SPOKE_SUBNET_ADDRESS_PREFIX = '172.16.0.0/22'

// Reference the existing Log Analytics Workspace
resource existingloganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// Deploy Hub vNET
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: VNET_HUB_NAME
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNET_HUB_ADDRESS_SPACE
      ]
    }
    subnets: [
      {
        name: AZFW_HUB_SUBNET_NAME
        properties: {
          addressPrefix: AZFW_HUB_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
        }
      }
      {
        name: BASTION_HUB_SUBNET_NAME
        properties: {
          addressPrefix: BASTION_HUB_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
        }
      }
      {
        name: GW_HUB_SUBNET_NAME
        properties: {
          addressPrefix: GW_HUB_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
        }
      }
      {
        name: APPGW_HUB_SUBNET_NAME
        properties: {
          addressPrefix: APPGW_HUB_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
        }
      }
    ]
  }
}

// Deploy Spoke vNET
resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: VNET_SPOKE_NAME
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNET_SPOKE_ADDRESS_SPACE
      ]
    }
    subnets: [
      {
        name: VM_SPOKE_SUBNET_NAME
        properties: {
          addressPrefix: VM_SPOKE_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
        }
      }
    ]
  }
}

// Deploy Diagnostic Setting on hubVnet
resource hubVnetdiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name : hubVnet.name
  scope: hubVnet
  properties: {
    workspaceId: existingloganalyticsworkspace.id
    logs: [
      {
        categoryGroup: 'AllLogs'
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

// Deploy Diagnostic Setting on spokeVnet
resource spokeVnetdiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name : spokeVnet.name
  scope: spokeVnet
  properties: {
    workspaceId: existingloganalyticsworkspace.id
    logs: [
      {
        categoryGroup: 'AllLogs'
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

// Deploy vNET Peering hubVnet to spokeVnet
resource vnetpeeringhub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: VNET_HUB_TO_SPOKE_PEERING
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
  }
}

// Deploy vNET Peering hubVnet to spokeVnet
resource vnetpeeringspoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: VNET_SPOKE_TO_HUB_PEERING
  parent: spokeVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}
output OUTPUT_LAW_RESOURCE_ID string = existingloganalyticsworkspace.id
