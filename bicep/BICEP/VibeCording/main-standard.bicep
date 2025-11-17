targetScope = 'subscription'

param Location string
param Environment string
param ProjectName string
param AdminEmail string
param BackupRetentionDays int
param LogRetentionDays int
// param CostBudgetAmount int  // Reserved for future cost budget implementation

var ResourceGroupName = 'rg-${ProjectName}-${Environment}-${Location}'
var Tags = {
  env: Environment
  project: ProjectName
  email: AdminEmail
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: ResourceGroupName
  location: Location
  tags: Tags
}

module logAnalyticsModule './modules/loganalytics.bicep' = {
  scope: resourceGroup
  name: 'logAnalyticsDeployment'
  params: {
    Location: Location
    Environment: Environment
    ProjectName: ProjectName
    Tags: Tags
    LogRetentionDays: LogRetentionDays
  }
}

module storageAccountModule './modules/storageaccount.bicep' = {
  scope: resourceGroup
  name: 'storageAccountDeployment'
  params: {
    Location: Location
    Environment: Environment
    ProjectName: ProjectName
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
  }
}

module nsgVmSubnetModule './modules/nsg.bicep' = {
  scope: resourceGroup
  name: 'nsgVmSubnetDeployment'
  params: {
    Location: Location
    NsgName: 'nsg-vmsubnet-${Environment}-${Location}'
    SecurityRules: [
      {
        name: 'AllowBastionSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.2.0/26'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '10.0.2.0/26'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
  }
}

module routeTableSpoke1Module './modules/routetable.bicep' = {
  scope: resourceGroup
  name: 'routeTableSpoke1Deployment'
  params: {
    Location: Location
    RouteTableName: 'rt-spoke1-${Environment}-${Location}'
    Routes: [
      {
        name: 'route-to-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewallModule.outputs.FirewallPrivateIp
        }
      }
    ]
    Tags: Tags
  }
}

module routeTableSpoke2Module './modules/routetable.bicep' = {
  scope: resourceGroup
  name: 'routeTableSpoke2Deployment'
  params: {
    Location: Location
    RouteTableName: 'rt-spoke2-${Environment}-${Location}'
    Routes: [
      {
        name: 'route-to-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewallModule.outputs.FirewallPrivateIp
        }
      }
    ]
    Tags: Tags
  }
}

module hubVnetModule './modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'hubVnetDeployment'
  params: {
    Location: Location
    VnetName: 'vnet-hub-${Environment}-${Location}'
    AddressPrefix: '10.0.0.0/16'
    Subnets: [
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.0.0/24'
        networkSecurityGroupId: null
        routeTableId: null
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.1.0/26'
        networkSecurityGroupId: null
        routeTableId: null
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.2.0/26'
        networkSecurityGroupId: null
        routeTableId: null
      }
    ]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
  }
}

module workspaceVnetModule './modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'workspaceVnetDeployment'
  params: {
    Location: Location
    VnetName: 'vnet-workspace-${Environment}-${Location}'
    AddressPrefix: '10.1.0.0/16'
    Subnets: [
      {
        name: 'private-endpoint-subnet'
        addressPrefix: '10.1.0.0/24'
        networkSecurityGroupId: null
        routeTableId: null
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
  }
}

module spoke1VnetModule './modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'spoke1VnetDeployment'
  params: {
    Location: Location
    VnetName: 'vnet-spoke1-${Environment}-${Location}'
    AddressPrefix: '192.168.0.0/16'
    Subnets: [
      {
        name: 'AppSubnet'
        addressPrefix: '192.168.0.0/24'
        networkSecurityGroupId: null
        routeTableId: routeTableSpoke1Module.outputs.RouteTableId
      }
      {
        name: 'DBSubnet'
        addressPrefix: '192.168.1.0/24'
        networkSecurityGroupId: null
        routeTableId: routeTableSpoke1Module.outputs.RouteTableId
      }
    ]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
  }
}

module spoke2VnetModule './modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'spoke2VnetDeployment'
  params: {
    Location: Location
    VnetName: 'vnet-spoke2-${Environment}-${Location}'
    AddressPrefix: '172.16.0.0/16'
    Subnets: [
      {
        name: 'VMSubnet'
        addressPrefix: '172.16.0.0/24'
        networkSecurityGroupId: nsgVmSubnetModule.outputs.NsgId
        routeTableId: routeTableSpoke2Module.outputs.RouteTableId
      }
    ]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
  }
}

module azureFirewallModule './modules/azfw.bicep' = {
  scope: resourceGroup
  name: 'azureFirewallDeployment'
  params: {
    Location: Location
    FirewallName: 'azfw-${Environment}-${Location}'
    SubnetId: hubVnetModule.outputs.SubnetIds[1]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
  }
}

module bastionModule './modules/bastion.bicep' = {
  scope: resourceGroup
  name: 'bastionDeployment'
  params: {
    Location: Location
    BastionName: 'bas-${Environment}-${Location}'
    SubnetId: hubVnetModule.outputs.SubnetIds[2]
    Tags: Tags
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
  }
}

module hubToSpoke1PeeringModule './modules/vnet-peering.bicep' = {
  scope: resourceGroup
  name: 'hubToSpoke1PeeringDeployment'
  params: {
    LocalVnetName: hubVnetModule.outputs.VnetName
    RemoteVnetName: spoke1VnetModule.outputs.VnetName
    RemoteVnetId: spoke1VnetModule.outputs.VnetId
    AllowForwardedTraffic: true
    AllowGatewayTransit: true
    UseRemoteGateways: false
  }
}

module spoke1ToHubPeeringModule './modules/vnet-peering.bicep' = {
  scope: resourceGroup
  name: 'spoke1ToHubPeeringDeployment'
  params: {
    LocalVnetName: spoke1VnetModule.outputs.VnetName
    RemoteVnetName: hubVnetModule.outputs.VnetName
    RemoteVnetId: hubVnetModule.outputs.VnetId
    AllowForwardedTraffic: true
    AllowGatewayTransit: false
    UseRemoteGateways: false
  }
}

module hubToSpoke2PeeringModule './modules/vnet-peering.bicep' = {
  scope: resourceGroup
  name: 'hubToSpoke2PeeringDeployment'
  params: {
    LocalVnetName: hubVnetModule.outputs.VnetName
    RemoteVnetName: spoke2VnetModule.outputs.VnetName
    RemoteVnetId: spoke2VnetModule.outputs.VnetId
    AllowForwardedTraffic: true
    AllowGatewayTransit: true
    UseRemoteGateways: false
  }
}

module spoke2ToHubPeeringModule './modules/vnet-peering.bicep' = {
  scope: resourceGroup
  name: 'spoke2ToHubPeeringDeployment'
  params: {
    LocalVnetName: spoke2VnetModule.outputs.VnetName
    RemoteVnetName: hubVnetModule.outputs.VnetName
    RemoteVnetId: hubVnetModule.outputs.VnetId
    AllowForwardedTraffic: true
    AllowGatewayTransit: false
    UseRemoteGateways: false
  }
}

module keyVaultModule './modules/keyvault.bicep' = {
  scope: resourceGroup
  name: 'keyVaultDeployment'
  params: {
    Location: Location
    KeyVaultName: 'kv-${ProjectName}-${Environment}'
    TenantId: subscription().tenantId
    Tags: Tags
    VmAdminUsername: 'azureuser01'
    VmAdminPassword: 'p@ssw0rd1234!'
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
  }
}

module managedIdentityModule './modules/u-managedid.bicep' = {
  scope: resourceGroup
  name: 'managedIdentityDeployment'
  params: {
    Location: Location
    IdentityName: 'id-${ProjectName}-${Environment}-${Location}'
    Tags: Tags
  }
}

module networkWatcherModule './modules/nwatcher.bicep' = {
  scope: resourceGroup
  name: 'networkWatcherDeployment'
  params: {
    Location: Location
    NetworkWatcherName: 'nw-${Environment}-${Location}'
    Tags: Tags
  }
}

module vmModule './modules/vm.bicep' = {
  scope: resourceGroup
  name: 'vmDeployment'
  params: {
    Location: Location
    VmNamePrefix: 'vm-${Environment}'
    VmSize: 'Standard_D4s_v3'
    AdminUsername: 'azureuser01'
    AdminPassword: 'p@ssw0rd1234!'
    SubnetId: spoke2VnetModule.outputs.SubnetIds[0]
    OsImagePublisher: 'Canonical'
    OsImageOffer: '0001-com-ubuntu-server-focal'
    OsImageSku: '20_04-lts-gen2'
    OsImageVersion: 'latest'
    InstanceCount: 2
    Tags: Tags
    ManagedIdentityId: managedIdentityModule.outputs.IdentityId
  }
}

module backupModule './modules/backup.bicep' = {
  scope: resourceGroup
  name: 'backupDeployment'
  params: {
    Location: Location
    VaultName: 'rsv-${Environment}-${Location}'
    BackupPolicyName: 'policy-daily-${Environment}'
    RetentionDays: BackupRetentionDays
    Tags: Tags
    VmIds: vmModule.outputs.VmIds
  }
}

module policyModule './modules/policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    Environment: Environment
    ProjectName: ProjectName
    AllowedLocations: [
      'japaneast'
      'japanwest'
    ]
  }
}

module rbacModule './modules/rbac.bicep' = {
  scope: resourceGroup
  name: 'rbacDeployment'
  params: {
    PrincipalId: managedIdentityModule.outputs.PrincipalId
  }
}

module alertRuleModule './modules/alertrule.bicep' = {
  scope: resourceGroup
  name: 'alertRuleDeployment'
  params: {
    ActionGroupName: 'ag-${Environment}-${Location}'
    AdminEmail: AdminEmail
    VmIds: vmModule.outputs.VmIds
    Tags: Tags
  }
}

module nsgFlowLogModule './modules/nsgflowlog.bicep' = {
  scope: resourceGroup
  name: 'nsgFlowLogDeployment'
  params: {
    Location: Location
    NetworkWatcherName: networkWatcherModule.outputs.NetworkWatcherName
    NsgId: nsgVmSubnetModule.outputs.NsgId
    NsgName: nsgVmSubnetModule.outputs.NsgName
    StorageAccountId: storageAccountModule.outputs.StorageAccountId
    LogAnalyticsWorkspaceId: logAnalyticsModule.outputs.WorkspaceId
    Tags: Tags
  }
}

module amplsModule './modules/ampls.bicep' = {
  scope: resourceGroup
  name: 'amplsDeployment'
  params: {
    PrivateLinkScopeName: 'ampls-${Environment}-${Location}'
    Location: 'global'
    Tags: Tags
  }
}

module amplsScopedResourceModule './modules/amplsscopedresource.bicep' = {
  scope: resourceGroup
  name: 'amplsScopedResourceDeployment'
  params: {
    PrivateLinkScopeName: 'ampls-${Environment}-${Location}'
    ScopedResourceName: logAnalyticsModule.outputs.WorkspaceName
    LinkedResourceId: logAnalyticsModule.outputs.WorkspaceId
  }
}

module privateEndpointLawModule './modules/privateendpoint.bicep' = {
  scope: resourceGroup
  name: 'privateEndpointLawDeployment'
  params: {
    Location: Location
    PrivateEndpointName: 'pe-law-${Environment}-${Location}'
    SubnetId: workspaceVnetModule.outputs.SubnetIds[0]
    PrivateLinkServiceId: amplsModule.outputs.PrivateLinkScopeId
    GroupIds: [
      'azuremonitor'
    ]
    Tags: Tags
  }
}

module privateEndpointStorageModule './modules/privateendpoint.bicep' = {
  scope: resourceGroup
  name: 'privateEndpointStorageDeployment'
  params: {
    Location: Location
    PrivateEndpointName: 'pe-storage-${Environment}-${Location}'
    SubnetId: workspaceVnetModule.outputs.SubnetIds[0]
    PrivateLinkServiceId: storageAccountModule.outputs.StorageAccountId
    GroupIds: [
      'blob'
    ]
    Tags: Tags
  }
}
