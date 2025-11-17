param Location string
param Environment string
param ProjectName string
param Tags object
param LogAnalyticsWorkspaceId string = ''

var StorageAccountName = 'st${toLower(replace(ProjectName, '-', ''))}${toLower(Environment)}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(StorageAccountName, 24)
  location: Location
  tags: Tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {}
}

resource diagnosticsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'diagnostics'
  properties: {
    publicAccess: 'None'
  }
}

resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(LogAnalyticsWorkspaceId)) {
  scope: storageAccount
  name: 'diag-${storageAccount.name}'
  properties: {
    workspaceId: LogAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output StorageAccountId string = storageAccount.id
output StorageAccountName string = storageAccount.name
