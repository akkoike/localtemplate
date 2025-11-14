// Storage Account with Private Endpoint module
param Location string
param StorageAccountName string
param SkuName string = 'Standard_LRS'
param WorkspaceVNetId string
param PrivateEndpointSubnetId string
param Tags object = {}

var privateEndpointName = '${StorageAccountName}-pe'
var privateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: StorageAccountName
  location: Location
  tags: Tags
  sku: {
    name: SkuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: Location
  tags: Tags
  properties: {
    subnet: {
      id: PrivateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: Tags
}

resource privateDnsZoneVNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${StorageAccountName}-vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: WorkspaceVNetId
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

output StorageAccountId string = storageAccount.id
output StorageAccountName string = storageAccount.name
output PrivateEndpointId string = privateEndpoint.id
