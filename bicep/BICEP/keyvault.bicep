/*
  GetStarted Bicep
    - Please set your user-objectID to ./keyvault-user.json file.
    - Please set your VM Admin Name/Password and User Object Name to variables.
*/

// Global variables
param location string = resourceGroup().location
var zoneNumber = '1'
var currentResourceGroupName = resourceGroup().name

module maindispatch './main.bicep' = {
  name: 'main'
  params: {
    location: location
    zoneNumber: zoneNumber
    currentResourceGroupName: currentResourceGroupName
  }
  dependsOn: [
    keyV
  ]
}

// Key Vault -----------------------------------------------------------------------------------------------
// Key Vault valiables
var KEY_VAULT_NAME = 'keyv${uniqueString(resourceGroup().id)}'
var USER_OBJECT_ID = loadJsonContent('./keyvault-user.json', 'UserObjectId001')
var SECRET_VMADMINPASS_NAME = 'vmadminpassword'
var SECRET_VMADMINPASS_VALUE = 'p@ssword1234'
var SECRET_USEROBJECTID_NAME = 'userobjectid'

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
        objectId: USER_OBJECT_ID
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
resource secretVmadminpassword 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: keyV
  name: SECRET_VMADMINPASS_NAME
  properties: {
    value: SECRET_VMADMINPASS_VALUE
    //contentType: 'password'
  }
}

// Set Key Vault Secret for User Object ID
resource secretUserobjectid 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: keyV
  name: SECRET_USEROBJECTID_NAME
  properties: {
    value: USER_OBJECT_ID
    //contentType: 'password'
  }
}
