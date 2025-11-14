// Virtual Network module
param VNetName string
param VNetAddressSpace string
param Location string
param Subnets array
param Tags object = {}

resource VirtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: VNetName
  location: Location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNetAddressSpace
      ]
    }
    subnets: [for subnet in Subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
}

output VNetId string = VirtualNetwork.id
output VNetName string = VirtualNetwork.name
output Subnets array = [for (subnet, i) in Subnets: {
  name: VirtualNetwork.properties.subnets[i].name
  id: VirtualNetwork.properties.subnets[i].id
  addressPrefix: VirtualNetwork.properties.subnets[i].properties.addressPrefix
}]
