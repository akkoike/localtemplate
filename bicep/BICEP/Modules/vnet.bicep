param location string
param logAnalyticsWorkspaceName string
// Tag valiables
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}
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
var DNSSERVER_HUB_SUBNET_NAME = 'DnsServerSubnet'
var DNS_HUB_SUBNET_ADDRESS_PREFIX = '192.168.4.0/29'

// Spoke vNET valiables
var VNET_SPOKE_NAME = 'vnet-poc-spoke-stag-001'
var VNET_SPOKE_ADDRESS_SPACE = '172.16.0.0/16'
var VM_SPOKE_SUBNET_NAME = 'VmSubnet'
var VM_SPOKE_SUBNET_ADDRESS_PREFIX = '172.16.0.0/22'

// DefaultRules for NSG Inbound
var NSG_HUB_INBOUND_NAME = 'nsg_inbound-poc-hub-stag-001'
var NSG_SPOKE_INBOUND_NAME = 'nsg_inbound-poc-spoke-stag-001'
var NSG_DEFAULT_RULES = loadJsonContent('../default-rule-nsg.json', 'DefaultRules')

// CustomRules for NSG Inbound (As you need you should uncomment this section and add your custom rules
/*
var customRules = [
  {
    name: 'Allow_Internet_HTTPS_Inbound'
    properties: {
      description: 'Allow inbound internet connectivity for HTTPS only.'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 400
      direction: 'Inbound'
    }
  }
]
*/
// NSG CustomRules variables for DNS Server Subnet on hub vNET
var nsghubcustomRules = [
  {
    name: 'Allow_DNS_Inbound_TCP'
    properties: {
      description: 'Allow inbound DNS connectivity from DNS Servers on on-premiss via ER/VPN'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow_DNS_Inbound_UDP'
    properties: {
      description: 'Allow inbound DNS connectivity from DNS Servers on on-premiss via ER/VPN'
      protocol: 'Udp'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 121
      direction: 'Inbound'
    }
  }
]

// Reference the existing Log Analytics Workspace
resource existingloganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// Deploy Hub vNET
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: VNET_HUB_NAME
  location: location
  tags: TAG_VALUE
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
      {
        name: DNSSERVER_HUB_SUBNET_NAME
        properties: {
          addressPrefix: DNS_HUB_SUBNET_ADDRESS_PREFIX
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureActiveDirectory'
            }
          ]
          networkSecurityGroup: {
            id: nsginboundhub.id
          }
        }
      }
    ]
  }
}

// Deploy Spoke vNET
resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: VNET_SPOKE_NAME
  location: location
  tags: TAG_VALUE
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
          networkSecurityGroup: {
            id: nsginboundspoke.id
          }
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

// Deploy NSG for hubVnet
resource nsginboundhub 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_HUB_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    //securityRules: NSG_DEFAULT_RULES
    securityRules: concat(NSG_DEFAULT_RULES, nsghubcustomRules)
  }
}

// Deploy NSG for spokeVnet
resource nsginboundspoke 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_SPOKE_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    securityRules: NSG_DEFAULT_RULES
    //securityRules: concat(NSG_DEFAULT_RULES, customRules)
  }
}

output OUTPUT_HUB_VNET_NAME string = VNET_HUB_NAME
