// Azure Bastion
param location string
param hubVnetName string
param logAnalyticsWorkspaceName string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Azure Firewall variables
var BASTION_NAME = 'bastion-poc-main-stag-001'
var BASTION_IF_NAME = 'bastionipconf-poc-main-stag-001'
var BASTION_PIP_NAME = 'bastionpip-poc-main-stag-001'
var BASTION_SKU = 'Standard'



// Reference the existing HubVNET
resource existinghubvnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}

// Deploy public IP for Azure Bastion
resource bastionpip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: BASTION_PIP_NAME
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

// Deploy Azure Bastion
resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: BASTION_NAME
  location: location
  tags: TAG_VALUE
  sku: {
    name: BASTION_SKU
  }
  properties: {
    ipConfigurations: [
      {
        name: BASTION_IF_NAME
        properties: {
          subnet: {
            id: existinghubvnet.properties.subnets[1].id
          }
          publicIPAddress: {
            id: bastionpip.id
          }
        }
      }
    ]
  }
}



output OUTPUT_BASTION_NAME string = bastion.name
