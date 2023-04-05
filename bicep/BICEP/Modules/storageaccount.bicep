// Storage Account
param location string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// Storage Account variables
var STORAGE_ACCOUNT_NSGFLOWLOGS_NAME = 'strnsgflow${uniqueString(resourceGroup().id)}'
var STORAGE_ACCOUNT_FORVM_NAME = 'strvm${uniqueString(resourceGroup().id)}'

// Deploy the Storage Account for NSG Flow Logs
resource storageaccountnsgflowlogs 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: STORAGE_ACCOUNT_NSGFLOWLOGS_NAME
  location: location
  tags: TAG_VALUE
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Deploy the Storage Account for VM
resource storageaccountvm 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: STORAGE_ACCOUNT_FORVM_NAME
  location: location
  tags: TAG_VALUE
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output OUTPUT_STORAGE_ACCOUNT_NSGFLOWLOG_ID string = storageaccountnsgflowlogs.id
output OUTPUT_STORAGE_ACCOUNT_NSGFLOWLOG_NAME string = storageaccountnsgflowlogs.name
output OUTPUT_STORAGE_ACCOUNT_VM_URI string = storageaccountvm.properties.primaryEndpoints.blob
output OUTPUT_STORAGE_ACCOUNT_VM_NAME string = storageaccountvm.name
