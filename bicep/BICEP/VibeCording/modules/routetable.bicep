// Route Table module
param location string
param routeTableName string
param azureFirewallPrivateIp string
param tags object

resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: 'default-route-to-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewallPrivateIp
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

output routeTableId string = routeTable.id
output routeTableName string = routeTable.name
