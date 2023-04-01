param appgwName string
param appgwpipName string
param appgwwafName string
param azfwName string
param azfwpipName string
param bastionName string
param bastionpipName string
param lawName string
param hubVnetName string
param spokeVnetName string
param amplsName string
param peName string
param nsgappgwwafName string
param nsgdnsName string
param nsgspokeName string
param straccName string

var USER_OBJECT_ID = loadJsonContent('./userparam.json', 'UserObjectId001')

// Deploy Managed IDentity (User Assigned) if needed
/*
param managedIdentityName string = 'MyUserManagedIdentity'
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}
*/

// RBAC Configuration ( default to Contributor role)
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
resource ownerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  // Owner
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}
resource readerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  // Reader
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// Reference application gateway
resource appgw 'Microsoft.Network/applicationGateways@2020-06-01' existing = {
  name: appgwName
}
// Reference application gateway WAF
resource appgwwaf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-09-01' existing = {
  name: appgwwafName
}
// Reference Azure Firewall
resource azfw 'Microsoft.Network/azureFirewalls@2020-06-01' existing = {
  name: azfwName
}
// Reference Azure Bastion
resource bastion 'Microsoft.Network/bastionHosts@2020-05-01' existing = {
  name: bastionName
}
// Reference Log Analytics Workspace
resource law 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: lawName
}
// Reference hub virtual network
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}
// Reference spoke virtual network
resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: spokeVnetName
}
// Reference Azure Monitor Private Link Scope
resource ampls 'microsoft.insights/privateLinkScopes@2021-07-01-preview' existing = {
  name: amplsName
}
// Reference Public IP for Azure Bastion
resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2020-05-01' existing = {
  name: bastionpipName
}
// Reference Public IP for Azure Firewall
resource azfwpip 'Microsoft.Network/publicIPAddresses@2020-05-01' existing = {
  name: azfwpipName
}
// Reference Public IP for Application Gateway
resource appgwpip 'Microsoft.Network/publicIPAddresses@2020-05-01' existing = {
  name: appgwpipName
}
// Reference Private Endpoint for Azure Monitor Private Link Scope
resource privateendpointampls 'Microsoft.Network/privateEndpoints@2020-05-01' existing = {
  name: peName
}
// Reference Network Security Group for Application Gateway WAF
resource nsgappgwwaf 'Microsoft.Network/networkSecurityGroups@2020-05-01' existing = {
  name: nsgappgwwafName
}
// Reference Network Security Group for DNS
resource nsgdns 'Microsoft.Network/networkSecurityGroups@2020-05-01' existing = {
  name: nsgdnsName
}
// Reference Network Security Group for Spoke
resource nsgspoke 'Microsoft.Network/networkSecurityGroups@2020-05-01' existing = {
  name: nsgspokeName
}
// Reference Storage Account for NSG Flow Logs
resource straccnsgflow 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: straccName
}

// RBAC assignment for application gateway
resource roleAssignmentappgw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appgw.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: appgw
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for application gateway WAF
resource roleAssignmentappgwwaf 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appgwwaf.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: appgwwaf
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Firewall
resource roleAssignmentazfw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azfw.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: azfw
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Bastion
resource roleAssignmentbastion 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(bastion.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: bastion
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Log Analytics Workspace
resource roleAssignmentlaw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(law.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: law
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for hub virtual network
resource roleAssignmenthubvnet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(hubVnet.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: hubVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for spoke virtual network
resource roleAssignmentspokevnet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(spokeVnet.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: spokeVnet
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Azure Monitor Private Link Scope
resource roleAssignmentampls 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(ampls.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: ampls
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Public IP of Azure Bastion
resource roleAssignmentpipbastion 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(bastionPublicIp.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: bastionPublicIp
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Public IP of Azure Firewall
resource roleAssignmentpipazfw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azfwpip.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: azfwpip
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Public IP of Application Gateway
resource roleAssignmentpipappgw 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appgwpip.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: appgwpip
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Private Endpoint of Azure Monitor Private Link Scope
resource roleAssignmentpeampls 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(privateendpointampls.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: privateendpointampls
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Network Security Group of Application Gateway WAF
resource roleAssignmentnsgappgwwaf 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(nsgappgwwaf.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: nsgappgwwaf
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Network Security Group of DNS
resource roleAssignmentnsgdns 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(nsgdns.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: nsgdns
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Network Security Group of Spoke
resource roleAssignmentnsgspoke 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(nsgspoke.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: nsgspoke
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
// RBAC assignment for Storage Account of NSG Flow Logs
resource roleAssignmentnsgflowlogs 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(straccnsgflow.id, USER_OBJECT_ID, contributorRoleDefinition.id)
  scope: straccnsgflow
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: USER_OBJECT_ID
    principalType: 'User'
  }
}
