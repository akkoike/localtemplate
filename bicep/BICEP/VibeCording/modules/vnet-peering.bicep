// VNet Peering module
param HubVNetName string
param HubVNetId string
param SpokeVNets array

resource HubVNet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: HubVNetName
}

resource HubToSpokeVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = [for spoke in SpokeVNets: {
  parent: HubVNet
  name: 'peer-${HubVNetName}-to-${spoke.name}'
  properties: {
    remoteVirtualNetwork: {
      id: spoke.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}]

resource SpokeToHubVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = [for spoke in SpokeVNets: {
  name: '${spoke.name}/peer-${spoke.name}-to-${HubVNetName}'
  properties: {
    remoteVirtualNetwork: {
      id: HubVNetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}]
