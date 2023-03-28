// Spoke vNET
param location string
param logAnalyticsWorkspaceName string
param azureFirewallName string
param principalId string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Spoke vNET valiables
var VNET_SPOKE_NAME = 'vnet-poc-spoke-stag-001'
var VNET_SPOKE_ADDRESS_SPACE = '172.16.0.0/16'
var VM_SPOKE_SUBNET_NAME = 'VmSubnet'
var VM_SPOKE_SUBNET_ADDRESS_PREFIX = '172.16.0.0/22'
var NSG_SPOKE_INBOUND_NAME = 'nsg_inbound-poc-spoke-stag-001'
var ROUTE_TABLE_NAME = 'rt-poc-main-stag-001'
var NSG_DEFAULT_SPOKE_RULES = loadJsonContent('../default-rule-spoke-nsg.json', 'DefaultRules')
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

// Reference the existing Log Analytics Workspace
resource existingloganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}
// Reference the existing Azure Firewall
resource azfw 'Microsoft.Network/azureFirewalls@2020-05-01' existing = {
  name: azureFirewallName
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
  name: guid(spokeVnet.id, principalId, contributorRoleDefinition.id)
  scope: spokeVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}

// Deploy Route Table for SpokeVNET
resource spokevnetroutetable 'Microsoft.Network/routeTables@2020-05-01' = {
  name: ROUTE_TABLE_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'RouteTableForSpokeVnet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfw.properties.ipConfigurations[0].properties.privateIPAddress
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
          routeTable: {
            id: spokevnetroutetable.id
          }
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

// Deploy NSG for spokeVnet
resource nsginboundspoke 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_SPOKE_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    securityRules: NSG_DEFAULT_SPOKE_RULES
    //securityRules: concat(NSG_DEFAULT_RULES, customRules)
  }
}

output OUTPUT_SPOKE_VNET_NAME string = spokeVnet.name
