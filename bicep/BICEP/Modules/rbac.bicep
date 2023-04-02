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

// Dispatch several RBAC assignments modules
module rbacampls './ScopeModules/Rbac/rbac-ampls.bicep' = {
  name: 'rbacampls'
  params: {
    amplsName: amplsName
  }
}
module rbacappgw './ScopeModules/Rbac/rbac-appgw.bicep' = {
  name: 'rbacappgw'
  params: {
    appgwName: appgwName
  }
}
module rbacappgwpip './ScopeModules/Rbac/rbac-appgwpip.bicep' = {
  name: 'rbacappgwpip'
  params: {
    appgwpipName: appgwpipName
  }
}
module rbacappgwwaf './ScopeModules/Rbac/rbac-appgwwaf.bicep' = {
  name: 'rbacappgwwaf'
  params: {
    appgwwafName: appgwwafName
  }
}
module rbacazfw './ScopeModules/Rbac/rbac-azfw.bicep' = {
  name: 'rbacazfw'
  params: {
    azfwName: azfwName
  }
}
module rbacbastion './ScopeModules/Rbac/rbac-bastion.bicep' = {
  name: 'rbacbastion'
  params: {
    bastionName: bastionName
  }
}
module rbachubvnet './ScopeModules/Rbac/rbac-hubvnet.bicep' = {
  name: 'rbachubvnet'
  params: {
    hubVnetName: hubVnetName
  }
}
module rbaclaw './ScopeModules/Rbac/rbac-law.bicep' = {
  name: 'rbaclaw'
  params: {
    lawName: lawName
  }
}
module rbacnsgappgwwaf './ScopeModules/Rbac/rbac-nsgappgwwaf.bicep' = {
  name: 'rbacnsgappgwwaf'
  params: {
    nsgappgwwafName: nsgappgwwafName
  }
}
module rbacnsgdns './ScopeModules/Rbac/rbac-nsgdns.bicep' = {
  name: 'rbacnsgdns'
  params: {
    nsgdnsName: nsgdnsName
  }
}
module rbacnsgspoke './ScopeModules/Rbac/rbac-nsgspoke.bicep' = {
  name: 'rbacnsgspoke'
  params: {
    nsgspokeName: nsgspokeName
  }
}
module rbacpe './ScopeModules/Rbac/rbac-pe.bicep' = {
  name: 'rbacpe'
  params: {
    peName: peName
  }
}
module rbacspokevnet './ScopeModules/Rbac/rbac-spokevnet.bicep' = {
  name: 'rbacspokevnet'
  params: {
    spokeVnetName: spokeVnetName
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
module rbacazfwpip './ScopeModules/Rbac/rbac-azfwpip.bicep' = {
  name: 'rbacazfwpip'
  params: {
    azfwpipName: azfwpipName
  }
}