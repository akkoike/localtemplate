param virtualNetworks_vnet_poc_hub_stag_001_name string = 'vnet-poc-hub-stag-001'
param virtualNetworks_vnet_poc_spoke_stag_001_name string = 'vnet-poc-spoke-stag-001'

resource virtualNetworks_vnet_poc_hub_stag_001_name_AppGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_hub_stag_001_name}/AppGwSubnet'
  properties: {
    addressPrefix: '192.168.3.0/27'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_poc_hub_stag_001_name_resource
  ]
}

resource virtualNetworks_vnet_poc_hub_stag_001_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_hub_stag_001_name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '192.168.1.0/26'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_poc_hub_stag_001_name_resource
  ]
}

resource virtualNetworks_vnet_poc_hub_stag_001_name_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_hub_stag_001_name}/AzureFirewallSubnet'
  properties: {
    addressPrefix: '192.168.0.0/26'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_poc_hub_stag_001_name_resource
  ]
}

resource virtualNetworks_vnet_poc_hub_stag_001_name_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_hub_stag_001_name}/GatewaySubnet'
  properties: {
    addressPrefix: '192.168.2.0/27'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_poc_hub_stag_001_name_resource
  ]
}

resource virtualNetworks_vnet_poc_spoke_stag_001_name_VmSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_spoke_stag_001_name}/VmSubnet'
  properties: {
    addressPrefix: '172.16.0.0/22'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_poc_spoke_stag_001_name_resource
  ]
}

resource virtualNetworks_vnet_poc_hub_stag_001_name_vnetpper_poc_hub_stag_001 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_hub_stag_001_name}/vnetpper-poc-hub-stag-001'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_poc_spoke_stag_001_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_poc_hub_stag_001_name_resource

  ]
}

resource virtualNetworks_vnet_poc_spoke_stag_001_name_vnetpper_poc_spoke_stag_001 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${virtualNetworks_vnet_poc_spoke_stag_001_name}/vnetpper-poc-spoke-stag-001'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_poc_hub_stag_001_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_poc_spoke_stag_001_name_resource

  ]
}

resource virtualNetworks_vnet_poc_spoke_stag_001_name_resource 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworks_vnet_poc_spoke_stag_001_name
  location: 'japaneast'
  tags: {
    CostCenterNumber: '10181378'
    date: '2023/03/21'
    division: 'Cloud Solution Architect Division1'
    location: 'japaneast'
    owner: 'akkoike'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'VmSubnet'
        id: virtualNetworks_vnet_poc_spoke_stag_001_name_VmSubnet.id
        properties: {
          addressPrefix: '172.16.0.0/22'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'vnetpper-poc-spoke-stag-001'
        id: virtualNetworks_vnet_poc_spoke_stag_001_name_vnetpper_poc_spoke_stag_001.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_poc_hub_stag_001_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          remoteAddressSpace: {
            addressPrefixes: [
              '192.168.0.0/16'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '192.168.0.0/16'
            ]
          }
        }
        type: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
      }
    ]
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet_poc_hub_stag_001_name_resource 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworks_vnet_poc_hub_stag_001_name
  location: 'japaneast'
  tags: {
    CostCenterNumber: '10181378'
    date: '2023/03/21'
    division: 'Cloud Solution Architect Division1'
    location: 'japaneast'
    owner: 'akkoike'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        id: virtualNetworks_vnet_poc_hub_stag_001_name_AzureFirewallSubnet.id
        properties: {
          addressPrefix: '192.168.0.0/26'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'AzureBastionSubnet'
        id: virtualNetworks_vnet_poc_hub_stag_001_name_AzureBastionSubnet.id
        properties: {
          addressPrefix: '192.168.1.0/26'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'GatewaySubnet'
        id: virtualNetworks_vnet_poc_hub_stag_001_name_GatewaySubnet.id
        properties: {
          addressPrefix: '192.168.2.0/27'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'AppGwSubnet'
        id: virtualNetworks_vnet_poc_hub_stag_001_name_AppGwSubnet.id
        properties: {
          addressPrefix: '192.168.3.0/27'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'vnetpper-poc-hub-stag-001'
        id: virtualNetworks_vnet_poc_hub_stag_001_name_vnetpper_poc_hub_stag_001.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_poc_spoke_stag_001_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          remoteAddressSpace: {
            addressPrefixes: [
              '172.16.0.0/16'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '172.16.0.0/16'
            ]
          }
        }
        type: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
      }
    ]
    enableDdosProtection: false
  }
}