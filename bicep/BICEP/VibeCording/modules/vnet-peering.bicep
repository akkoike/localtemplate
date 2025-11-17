param LocalVnetName string
param RemoteVnetName string
param RemoteVnetId string
param AllowForwardedTraffic bool
param AllowGatewayTransit bool
param UseRemoteGateways bool

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: LocalVnetName
}

resource peeringToRemote 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  parent: virtualNetwork
  name: '${LocalVnetName}-to-${RemoteVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: RemoteVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: AllowForwardedTraffic
    allowGatewayTransit: AllowGatewayTransit
    useRemoteGateways: UseRemoteGateways
  }
}

output PeeringId string = peeringToRemote.id
