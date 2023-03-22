//param location string = 'japaneast'
param location string = resourceGroup().location

// Log Analytics Workspace module
module loganalyticsmodule 'Modules/law.bicep' = {
  name: 'law-modulename'
  params: {
    location: location
  }
}

// vNET module
module vnetmodule 'Modules/vnet.bicep' = {
  name: 'vnet-modulename'
  params: {
    location: location
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
  }
  dependsOn: [
    loganalyticsmodule
  ]
}
