// Azure Bastion
param location string
param hubVnetName string
param bastionSubnetName string
param logAnalyticsWorkspaceName string
param principalId string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Azure Bastion variables
var BASTION_NAME = 'bastion-poc-main-stag-001'
var BASTION_IF_NAME = 'bastionipconf-poc-main-stag-001'
var BASTION_PIP_NAME = 'bastionpip-poc-main-stag-001'
var BASTION_SKU = 'Standard'

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
  name: guid(bastion.id, principalId, contributorRoleDefinition.id)
  scope: bastion
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}

// Reference the existing HubVNET
resource existinghubvnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
  resource existingbastionsubnet 'subnets' existing = {
    name: bastionSubnetName
  }
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
            id: existinghubvnet::existingbastionsubnet.id
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
