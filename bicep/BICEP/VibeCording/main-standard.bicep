// ========================================
// Azure 標準化環境 - メインテンプレート
// ========================================
// このテンプレートは、Hub-Spoke トポロジーに基づく
// Azure標準化環境を構築します
//
// 構成要素:
// - 4つのVNet (Hub, Workspace, Spoke1, Spoke2)
// - VNet Peering (Hub-Spoke)
// - Azure Firewall
// - Azure Bastion
// - Storage Account (Private Endpoint)
// - Log Analytics Workspace (AMPLS)
// - Key Vault
// - Virtual Machines with Backup
// - NSG and Route Tables
// ========================================

// ========================================
// パラメータ定義
// ========================================

@description('環境識別子 (dev, stag, prod)')
@allowed([
  'dev'
  'stag'
  'prod'
])
param Environment string

@description('Azure リージョン')
param Location string = 'japaneast'

@description('プロジェクト名プレフィックス')
param ProjectName string = 'azstd'

@description('管理者メールアドレス')
param AdminEmail string = 'akkoike@microsoft.com'

@description('Azure AD テナント ID')
param TenantId string = tenant().tenantId

@description('VM管理者パスワード')
@secure()
param VmAdminPassword string

// ========================================
// 変数定義
// ========================================

var ResourcePrefix = '${ProjectName}-${Environment}'

var CommonTags = {
  env: Environment
  project: ProjectName
  owner: AdminEmail
  managedBy: 'Bicep'
}

// Hub VNet 設定
var HubVNetConfig = {
  name: '${ResourcePrefix}-vnet-hub'
  addressSpace: '10.0.0.0/16'
  subnets: [
    {
      name: 'GatewaySubnet'
      addressPrefix: '10.0.0.0/24'
    }
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: '10.0.1.0/26'
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '10.0.2.0/26'
    }
  ]
}

// Workspace VNet 設定
var WorkspaceVNetConfig = {
  name: '${ResourcePrefix}-vnet-workspace'
  addressSpace: '10.1.0.0/16'
  subnets: [
    {
      name: 'private-endpoint-subnet'
      addressPrefix: '10.1.0.0/24'
    }
  ]
}

// Spoke1 VNet 設定
var Spoke1VNetConfig = {
  name: '${ResourcePrefix}-vnet-spoke1'
  addressSpace: '192.168.0.0/16'
  subnets: [
    {
      name: 'AppSubnet'
      addressPrefix: '192.168.0.0/24'
    }
    {
      name: 'DBSubnet'
      addressPrefix: '192.168.1.0/24'
    }
  ]
}

// Spoke2 VNet 設定
var Spoke2VNetConfig = {
  name: '${ResourcePrefix}-vnet-spoke2'
  addressSpace: '172.16.0.0/16'
  subnets: [
    {
      name: 'VMSubnet'
      addressPrefix: '172.16.0.0/24'
    }
  ]
}

// Storage Account 設定
var StorageAccountConfig = {
  name: replace('${ResourcePrefix}st', '-', '')
  skuName: Environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
}

// Log Analytics 設定
var LogAnalyticsConfig = {
  name: '${ResourcePrefix}-law'
  retentionInDays: 90
}

// Key Vault 設定
var KeyVaultConfig = {
  name: '${ResourcePrefix}-kv'
}

// Recovery Services Vault 設定
var BackupVaultConfig = {
  name: '${ResourcePrefix}-rsv'
}

// Azure Firewall のプライベート IP
var AzureFirewallPrivateIp = '10.0.1.4'

// ========================================
// NSG リソース
// ========================================

// AppSubnet 用 NSG
module nsgAppSubnet './modules/nsg.bicep' = {
  name: 'deploy-nsg-app-subnet'
  params: {
    location: Location
    nsgName: '${ResourcePrefix}-nsg-app'
    tags: CommonTags
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// DBSubnet 用 NSG
module nsgDbSubnet './modules/nsg.bicep' = {
  name: 'deploy-nsg-db-subnet'
  params: {
    location: Location
    nsgName: '${ResourcePrefix}-nsg-db'
    tags: CommonTags
    securityRules: [
      {
        name: 'AllowSqlFromApp'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: Spoke1VNetConfig.subnets[0].addressPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// VMSubnet 用 NSG
module nsgVmSubnet './modules/nsg.bicep' = {
  name: 'deploy-nsg-vm-subnet'
  params: {
    location: Location
    nsgName: '${ResourcePrefix}-nsg-vm'
    tags: CommonTags
    securityRules: [
      {
        name: 'AllowBastionInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: HubVNetConfig.subnets[2].addressPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Private Endpoint Subnet 用 NSG
module nsgPeSubnet './modules/nsg.bicep' = {
  name: 'deploy-nsg-pe-subnet'
  params: {
    location: Location
    nsgName: '${ResourcePrefix}-nsg-pe'
    tags: CommonTags
    securityRules: [
      {
        name: 'AllowPrivateEndpointInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ========================================
// VNet リソース
// ========================================

// Hub VNet
module hubVNet './modules/vnet.bicep' = {
  name: 'deploy-hub-vnet'
  params: {
    VNetName: HubVNetConfig.name
    VNetAddressSpace: HubVNetConfig.addressSpace
    Location: Location
    Subnets: HubVNetConfig.subnets
    Tags: CommonTags
  }
}

// Workspace VNet
module workspaceVNet './modules/vnet.bicep' = {
  name: 'deploy-workspace-vnet'
  params: {
    VNetName: WorkspaceVNetConfig.name
    VNetAddressSpace: WorkspaceVNetConfig.addressSpace
    Location: Location
    Subnets: WorkspaceVNetConfig.subnets
    Tags: CommonTags
  }
}

// Spoke1 VNet
module spoke1VNet './modules/vnet.bicep' = {
  name: 'deploy-spoke1-vnet'
  params: {
    VNetName: Spoke1VNetConfig.name
    VNetAddressSpace: Spoke1VNetConfig.addressSpace
    Location: Location
    Subnets: Spoke1VNetConfig.subnets
    Tags: CommonTags
  }
}

// Spoke2 VNet
module spoke2VNet './modules/vnet.bicep' = {
  name: 'deploy-spoke2-vnet'
  params: {
    VNetName: Spoke2VNetConfig.name
    VNetAddressSpace: Spoke2VNetConfig.addressSpace
    Location: Location
    Subnets: Spoke2VNetConfig.subnets
    Tags: CommonTags
  }
}

// ========================================
// VNet Peering
// ========================================

module vnetPeering './modules/vnet-peering.bicep' = {
  name: 'deploy-vnet-peering'
  params: {
    HubVNetName: hubVNet.outputs.VNetName
    HubVNetId: hubVNet.outputs.VNetId
    SpokeVNets: [
      {
        name: workspaceVNet.outputs.VNetName
        id: workspaceVNet.outputs.VNetId
      }
      {
        name: spoke1VNet.outputs.VNetName
        id: spoke1VNet.outputs.VNetId
      }
      {
        name: spoke2VNet.outputs.VNetName
        id: spoke2VNet.outputs.VNetId
      }
    ]
  }
}

// ========================================
// Route Table
// ========================================

// Spoke1 Route Table
module routeTableSpoke1 './modules/routetable.bicep' = {
  name: 'deploy-routetable-spoke1'
  params: {
    location: Location
    routeTableName: '${ResourcePrefix}-rt-spoke1'
    azureFirewallPrivateIp: AzureFirewallPrivateIp
    tags: CommonTags
  }
}

// Spoke2 Route Table
module routeTableSpoke2 './modules/routetable.bicep' = {
  name: 'deploy-routetable-spoke2'
  params: {
    location: Location
    routeTableName: '${ResourcePrefix}-rt-spoke2'
    azureFirewallPrivateIp: AzureFirewallPrivateIp
    tags: CommonTags
  }
}

// ========================================
// Log Analytics Workspace
// ========================================

module logAnalytics './modules/loganalytics.bicep' = {
  name: 'deploy-log-analytics'
  params: {
    Location: Location
    WorkspaceName: LogAnalyticsConfig.name
    RetentionInDays: LogAnalyticsConfig.retentionInDays
    Tags: CommonTags
  }
}

// ========================================
// Storage Account
// ========================================

module storageAccount './modules/storageaccount.bicep' = {
  name: 'deploy-storage-account'
  params: {
    Location: Location
    StorageAccountName: StorageAccountConfig.name
    SkuName: StorageAccountConfig.skuName
    WorkspaceVNetId: workspaceVNet.outputs.VNetId
    PrivateEndpointSubnetId: workspaceVNet.outputs.Subnets[0].id
    Tags: CommonTags
  }
}

// ========================================
// Key Vault
// ========================================

module keyVault './modules/keyvault.bicep' = {
  name: 'deploy-key-vault'
  params: {
    location: Location
    keyVaultName: KeyVaultConfig.name
    tenantId: TenantId
    tags: CommonTags
    enablePublicNetworkAccess: true
    adminPassword: VmAdminPassword
  }
}

// ========================================
// Recovery Services Vault
// ========================================

module backupVault './modules/backup.bicep' = {
  name: 'deploy-backup-vault'
  params: {
    location: Location
    vaultName: BackupVaultConfig.name
    tags: CommonTags
    retentionDays: 30
  }
}

// ========================================
// Virtual Machines (Spoke1)
// ========================================

module vmSpoke1Zone1 './modules/vm.bicep' = {
  name: 'deploy-vm-spoke1-zone1'
  params: {
    location: Location
    vmName: '${ResourcePrefix}-vm-spoke1-z1'
    vmSize: 'Standard_D4s_v3'
    availabilityZone: '1'
    subnetId: spoke1VNet.outputs.Subnets[0].id
    adminUsername: 'azureuser01'
    adminPassword: VmAdminPassword
    tags: CommonTags
  }
  dependsOn: [
    keyVault
  ]
}

module vmSpoke1Zone2 './modules/vm.bicep' = {
  name: 'deploy-vm-spoke1-zone2'
  params: {
    location: Location
    vmName: '${ResourcePrefix}-vm-spoke1-z2'
    vmSize: 'Standard_D4s_v3'
    availabilityZone: '2'
    subnetId: spoke1VNet.outputs.Subnets[0].id
    adminUsername: 'azureuser01'
    adminPassword: VmAdminPassword
    tags: CommonTags
  }
  dependsOn: [
    keyVault
  ]
}

// ========================================
// Virtual Machines (Spoke2)
// ========================================

module vmSpoke2Zone1 './modules/vm.bicep' = {
  name: 'deploy-vm-spoke2-zone1'
  params: {
    location: Location
    vmName: '${ResourcePrefix}-vm-spoke2-z1'
    vmSize: 'Standard_D4s_v3'
    availabilityZone: '1'
    subnetId: spoke2VNet.outputs.Subnets[0].id
    adminUsername: 'azureuser01'
    adminPassword: VmAdminPassword
    tags: CommonTags
  }
  dependsOn: [
    keyVault
  ]
}

module vmSpoke2Zone2 './modules/vm.bicep' = {
  name: 'deploy-vm-spoke2-zone2'
  params: {
    location: Location
    vmName: '${ResourcePrefix}-vm-spoke2-z2'
    vmSize: 'Standard_D4s_v3'
    availabilityZone: '2'
    subnetId: spoke2VNet.outputs.Subnets[0].id
    adminUsername: 'azureuser01'
    adminPassword: VmAdminPassword
    tags: CommonTags
  }
  dependsOn: [
    keyVault
  ]
}

// ========================================
// 出力
// ========================================

@description('Hub VNet リソース ID')
output HubVNetId string = hubVNet.outputs.VNetId

@description('Workspace VNet リソース ID')
output WorkspaceVNetId string = workspaceVNet.outputs.VNetId

@description('Spoke1 VNet リソース ID')
output Spoke1VNetId string = spoke1VNet.outputs.VNetId

@description('Spoke2 VNet リソース ID')
output Spoke2VNetId string = spoke2VNet.outputs.VNetId

@description('Log Analytics Workspace ID')
output LogAnalyticsWorkspaceId string = logAnalytics.outputs.WorkspaceId

@description('Storage Account 名')
output StorageAccountName string = storageAccount.outputs.StorageAccountName

@description('Key Vault 名')
output KeyVaultName string = keyVault.outputs.keyVaultName

@description('Backup Vault 名')
output BackupVaultName string = backupVault.outputs.vaultName

@description('VM Spoke1 Zone1 リソース ID')
output VmSpoke1Zone1Id string = vmSpoke1Zone1.outputs.vmId

@description('VM Spoke1 Zone2 リソース ID')
output VmSpoke1Zone2Id string = vmSpoke1Zone2.outputs.vmId

@description('VM Spoke2 Zone1 リソース ID')
output VmSpoke2Zone1Id string = vmSpoke2Zone1.outputs.vmId

@description('VM Spoke2 Zone2 リソース ID')
output VmSpoke2Zone2Id string = vmSpoke2Zone2.outputs.vmId
