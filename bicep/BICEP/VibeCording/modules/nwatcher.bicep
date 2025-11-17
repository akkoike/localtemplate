param Location string
param NetworkWatcherName string
param Tags object

resource networkWatcher 'Microsoft.Network/networkWatchers@2023-11-01' = {
  name: NetworkWatcherName
  location: Location
  tags: Tags
  properties: {}
}

output NetworkWatcherId string = networkWatcher.id
output NetworkWatcherName string = networkWatcher.name
