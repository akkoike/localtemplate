// Hub vNET
param location string
param logAnalyticsWorkspaceName string
param principalId string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}
// Hub vNET/Subnet valiables
var VNET_HUB_NAME = 'vnet-poc-hub-stag-001'
var VNET_HUB_ADDRESS_SPACE = '192.168.0.0/16'
var AZFW_HUB_SUBNET_NAME = 'AzureFirewallSubnet'
var AZFW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.0.0/26'
var BASTION_HUB_SUBNET_NAME = 'AzureBastionSubnet'
var BASTION_HUB_SUBNET_ADDRESS_PREFIX = '192.168.1.0/26'
var GW_HUB_SUBNET_NAME = 'GatewaySubnet'
var GW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.2.0/27'
var APPGW_HUB_SUBNET_NAME = 'AppGwSubnet'
var APPGW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.3.0/27'
var DNS_HUB_SUBNET_NAME = 'DnsHubSubnet'
var DNS_HUB_SUBNET_ADDRESS_PREFIX = '192.168.4.0/28'

// DefaultRules for NSG Inbound
var NSG_HUB_INBOUND_NAME = 'nsg_inbound-poc-hub-stag-001'
var NSG_DEFAULT_HUB_RULES = loadJsonContent('../default-rule-hub-nsg.json', 'DefaultRules')
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
var NSG_HUB_CUSTOM_RULES = [
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

// RBAC Configuration
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  //scope: subscription()
  // Owner
  //name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  // Contributer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // Reader
  //name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// RBAC assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(hubVnet.id, principalId, contributorRoleDefinition.id)
  scope: hubVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
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
        name: DNS_HUB_SUBNET_NAME
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

// Deploy NSG for hubVnet
resource nsginboundhub 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_HUB_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    //securityRules: NSG_DEFAULT_RULES
    securityRules: concat(NSG_DEFAULT_HUB_RULES, NSG_HUB_CUSTOM_RULES)
  }
}

output OUTPUT_HUB_VNET_NAME string = VNET_HUB_NAME
