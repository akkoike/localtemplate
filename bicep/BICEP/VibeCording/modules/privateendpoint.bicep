param Location string
param PrivateEndpointName string
param SubnetId string
param PrivateLinkServiceId string
param GroupIds array
param Tags object

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: PrivateEndpointName
  location: Location
  tags: Tags
  properties: {
    subnet: {
      id: SubnetId
    }
    privateLinkServiceConnections: [
      {
        name: PrivateEndpointName
        properties: {
          privateLinkServiceId: PrivateLinkServiceId
          groupIds: GroupIds
        }
      }
    ]
  }
}

output PrivateEndpointId string = privateEndpoint.id
output PrivateEndpointName string = privateEndpoint.name
