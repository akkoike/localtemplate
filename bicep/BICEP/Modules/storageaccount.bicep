// Storage Account
param location string

// Storage Account variables
var STORAGE_ACCOUNT_NSGFLOWLOGS_NAME = 'strnsgflow${uniqueString(resourceGroup().id)}'

// Deploy the Storage Account for NSG Flow Logs
resource storageaccountnsgflowlogs 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: STORAGE_ACCOUNT_NSGFLOWLOGS_NAME
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output OUTPUT_STORAGE_ACCOUNT_NSGFLOWLOG_ID string = storageaccountnsgflowlogs.id
