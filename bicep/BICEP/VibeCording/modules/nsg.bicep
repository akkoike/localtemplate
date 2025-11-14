// NSG module
param location string
param nsgName string
param securityRules array = []
param tags object

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
output nsgName string = nsg.name
