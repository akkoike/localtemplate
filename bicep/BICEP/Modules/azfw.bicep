// Azure Firewall
param location string
param hubVnetName string
param azfwSubnetName string
param zonenumber string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Azure Firewall variables
var AZFW_NAME = 'azfw-poc-main-stag-001'
var AZFW_IF_NAME = 'azfwipconf-poc-main-stag-001'
var AZFW_PIP_NAME = 'azfwpip-poc-main-stag-001'
var AZFW_SKU = 'Standard'

// Default Azure Firewall Application Rule
var AZFW_DEFAULT_RULE = loadJsonContent('../default-azfw-apprule.json', 'rules')
// As you need you should uncomment this section and add your custom application rules
/*
var AZFW_APP_RULE_CUSTOM_RULES = [
  {
            name: 'hogehoge.com'
            protocols: [
                {
                    protocolType: 'Http'
                    port: 80
                }
                {
                    protocolType: 'https'
                    port: 443
                }
            ]
            fqdnTags: []
            targetFqdns: '*.hogehoge.com'
            sourceAddresses: '*'
            sourceIpGroups: []
  }
]
*/

// Default Azure Firewall Network Rule
var AZFW_DEFAULT_NETWORK_RULE = loadJsonContent('../default-azfw-nwrule.json', 'rules')

// Reference the existing HubVNET
resource existinghubvnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
  resource existingazfwsubnet 'subnets' existing = {
    name: azfwSubnetName
  }
}

// Deploy public IP for Azure Firewall
resource azfwpip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: AZFW_PIP_NAME
  location: location
  tags: TAG_VALUE
  zones: [zonenumber]
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
  zones: [zonenumber]
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
          id: existinghubvnet::existingazfwsubnet.id
        }
        publicIPAddress: {
          id: azfwpip.id
        }
      }
    }
  ]
  applicationRuleCollections: [
    {
      name: 'default-azfw-apprule'
      properties: {
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: AZFW_DEFAULT_RULE
        //rules: concat(AZFW_DEFAULT_RULE, AZFW_APP_RULE_CUSTOM_RULES)
      }
    }
  ]
  networkRuleCollections: [
    {
      name: 'default-azfw-nwrule'
      properties: {
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: AZFW_DEFAULT_NETWORK_RULE
      }
    }
  ]
  natRuleCollections: []
  }
}

output OUTPUT_AZFW_NAME string = azfw.name
output OUTPUT_AZFW_PIP_NAME string = azfwpip.name
