// vNET Peering between hubVnet and spokeVnet
param hubVnetName string
param spokeVnetName string

// vNET Peering variables
var VNET_HUB_TO_SPOKE_PEERING = 'vnetpeering-poc-hub2spoke-001'
var VNET_SPOKE_TO_HUB_PEERING = 'vnetpeering-poc-spoke2hub-001'

// Reference the hubVnet
resource hubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}

// Reference the spokeVnet
resource spokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: spokeVnetName
}

// Deploy vNET Peering hubVnet to spokeVnet
resource vnetpeeringhub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: VNET_HUB_TO_SPOKE_PEERING
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
  }
}

// Deploy vNET Peering hubVnet to spokeVnet
resource vnetpeeringspoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: VNET_SPOKE_TO_HUB_PEERING
  parent: spokeVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}
