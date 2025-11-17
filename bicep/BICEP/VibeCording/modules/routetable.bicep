param Location string
param RouteTableName string
param Routes array
param Tags object

resource routeTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: RouteTableName
  location: Location
  tags: Tags
  properties: {
    routes: Routes
    disableBgpRoutePropagation: false
  }
}

output RouteTableId string = routeTable.id
output RouteTableName string = routeTable.name
