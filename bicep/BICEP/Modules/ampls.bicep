// Azure Monitor Prinvate Link Scope 
param location string
param hubVnetName string
param dnsSubnetName string
param pridnszonelist array = [
  'monitor.azure.com'
  'oms.opinsights.azure.com'
  'ods.opinsights.azure.com'
  'agentsvc.azure-automation.net'
  'blob.windows.core.net'
]

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// AMPLS/Private Endpoint/Private DNS Zone variables
var AMPLS_NAME = 'ampls-poc-main-stag-001'
var PE_NAME = 'pe-poc-main-stag-001'
var PLS_NAME = 'pls-poc-main-stag-001'
var PDNS_ZONE_GROUP_NAME = 'zonegroup-poc-main-stag-001'

// Reference existing hub-vNET
resource existinghubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
  resource existingdnssubnet 'subnets' existing = {
    name: dnsSubnetName
  }
}

// Deploy Azure Monitor Private Link Scopes resource
resource ampls 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: AMPLS_NAME
  location: 'global'
  tags: TAG_VALUE
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'Open'
    }
  }
}

// Deploy Private Endpoint resource
resource peampls 'Microsoft.Network/privateEndpoints@2022-09-01' = {
    name: PE_NAME
    location: location
    tags: TAG_VALUE
    properties: {
      subnet: {
        id: existinghubVnet::existingdnssubnet.id
      }
      privateLinkServiceConnections: [
        {
          name: PLS_NAME
          properties: {
            privateLinkServiceId: ampls.id
            groupIds: [
              'AzureMonitor'
            ]
          }
        }
      ]
    }
  }

// Deploy Private DNS Zone resource
resource pridnszoneforampls 'Microsoft.Network/privateDnsZones@2020-06-01' = [for pridnszone in pridnszonelist: {
    name: 'privatelink.${pridnszone}'
    location: 'global'
    tags: TAG_VALUE
    properties: {
    }
}]

// Deploy Private DNS Zone Group resource
resource pridnszoneforamplsgroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
    parent: peampls
    name: PDNS_ZONE_GROUP_NAME
    properties: {
      privateDnsZoneConfigs: [
        {
          name: pridnszoneforampls[0].name
          properties: {
            privateDnsZoneId: pridnszoneforampls[0].id
          }
        }
        {
          name: pridnszoneforampls[1].name
          properties: {
            privateDnsZoneId: pridnszoneforampls[1].id
          }
        }
        {
          name: pridnszoneforampls[2].name
          properties: {
            privateDnsZoneId: pridnszoneforampls[2].id
          }
        }
        {
          name: pridnszoneforampls[3].name
          properties: {
            privateDnsZoneId: pridnszoneforampls[3].id
          }
        }
        {
          name: pridnszoneforampls[4].name
          properties: {
            privateDnsZoneId: pridnszoneforampls[4].id
          }
        }
      ]
    }
}

output OUTPUT_AMPLS_NAME string = ampls.name
output OUTPUT_PE_NAME string = peampls.name
