/*
  Before starting getStart.bicep, please do the following.
    - Please set your user-objectID to ./keyvault-user.json and ./Modules/ScopeModules/Rbac/*.json
      And please set your Admin Password to login ubuntu VM (default: p@ssword1234)
  
    - run the getStart.bicep from Visual Studio Code
      Automatically deploy the following resources.
        - Resource Group
        - Key Vault
        - Key Vault Secret
        - Virtual Network
        - Subnet
        - Network Security Group
        - Network Security Group Rule
        - Network Interface
        - Route Table
        - Public IP Address
        - Virtual Machine
        - Azure Managed Disk
        - Virtual Machine Extension
        - Azure Firewall
        - Azure Firewall Net/App rules
        - Azure Bastion
        - Storage Account
        - Log Analytics Workspace
        - Azure Monitor Private Link Scope
        - Azure Monitor Private Link Scope Private Endpoint
        - Azure Private DNS Zone
        - Azure Application Gateway
        - Azure Web Application Firewall Policy
        - RBAC
        - Diagnostic Settings
*/

// Global variables
param location string = resourceGroup().location
var zoneNumber = '1'
var currentResourceGroupName = resourceGroup().name

// Main module
module main 'main.bicep' = {
  name: 'main'
  params: {
    location: location
    zoneNumber: zoneNumber
    currentResourceGroupName: currentResourceGroupName
    keyvaultName: keyV.name
    keyvaultSecretVmadminpasswordName: secretVmadmin.name
  }
}

// Key Vault -----------------------------------------------------------------------------------------------
// Key Vault valiables
var KEY_VAULT_NAME = 'keyv${uniqueString(resourceGroup().id)}'
var SECRET_VMADMIN_NAME = 'vmadminpassword'
var SECRET_VMADMINPASS_VALUE = loadJsonContent('./keyvault-pass.json')

// Tag Values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Deploy Key Vault
resource keyV 'Microsoft.KeyVault/vaults@2020-04-01-preview' = {
  name: KEY_VAULT_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: SECRET_USER_OBJECTID_VALUE.userobjectid
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'update'
            'import'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
          ]
          certificates: [
            'get'
            'list'
            'delete'
            'create'
            'import'
            'update'
            'managecontacts'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
            'manageissuers'
            'recover'
            'purge'
          ]
          storage: [
            'get'
            'list'
            'delete'
            'set'
            'update'
            'regeneratekey'
            'setsas'
            'listsas'
            'getsas'
            'deletesas'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    //vaultUri: ''
  }
}

// Set Key Vault Secret for VM Admin Password
resource secretVmadmin 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: keyV
  name: SECRET_VMADMIN_NAME
  properties: {
    value: SECRET_VMADMINPASS_VALUE.vmadminpassword
    //contentType: 'password'
  }
}
