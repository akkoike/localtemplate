// Hub vNET
param location string

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
var APPGW_HUB_SUBNET_ADDRESS_PREFIX = '192.168.3.0/24'
var DNS_HUB_SUBNET_NAME = 'DnsHubSubnet'
var DNS_HUB_SUBNET_ADDRESS_PREFIX = '192.168.4.0/26'

// DefaultRules for NSG Inbound
var NSG_DNS_INBOUND_NAME = 'nsg_inbound-poc-dns-stag-001'
var NSG_DEFAULT_RULES = loadJsonContent('../default-rule-hub-nsg.json', 'DefaultRules')
var NSG_APPGW_INBOUND_NAME = 'nsg_inbound-poc-appgwwaf-stag-001'
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
var NSG_DNS_CUSTOM_RULES = [
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

// NSG CustomRules variables for AppGW Subnet (WAF_V2) on hub vNET
var NSG_APPGW_CUSTOM_RULES = [
  {
    name: 'Allow_APPGW_Inbound_TCP'
    properties: {
      description: 'Allow inbound traffic from Internet to AppGW'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '65200-65535'
      sourceAddressPrefix: 'GatewayManager'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
]  

// Deploy NSG for dns subnet
resource nsginbounddns 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_DNS_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    //securityRules: NSG_DEFAULT_RULES
    securityRules: concat(NSG_DEFAULT_RULES, NSG_DNS_CUSTOM_RULES)
  }
}

// Deploy NSG for appgw subnet
resource nsginboundappgw 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NSG_APPGW_INBOUND_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    //securityRules: NSG_DEFAULT_RULES
    securityRules: NSG_APPGW_CUSTOM_RULES
  }
}

// Deploy Hub vNET
resource hubVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
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
          networkSecurityGroup: {
            id: nsginboundappgw.id
          }
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
            id: nsginbounddns.id
          }
        }
      }
    ]
  }
}

output OUTPUT_HUB_VNET_NAME string = hubVnet.name
output OUTPUT_AZFW_HUB_SUBNET_NAME string = AZFW_HUB_SUBNET_NAME
output OUTPUT_BASTION_HUB_SUBNET_NAME string = BASTION_HUB_SUBNET_NAME
output OUTPUT_GW_HUB_SUBNET_NAME string = GW_HUB_SUBNET_NAME
output OUTPUT_APPGW_HUB_SUBNET_NAME string = APPGW_HUB_SUBNET_NAME
output OUTPUT_DNS_HUB_SUBNET_NAME string = DNS_HUB_SUBNET_NAME
output OUTPUT_NSG_DNS_INBOUND_NAME string = nsginbounddns.name
output OUTPUT_NSG_APPGW_INBOUND_NAME string = nsginboundappgw.name
