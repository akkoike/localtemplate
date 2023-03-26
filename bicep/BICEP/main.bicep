// Global variables
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

// Azure Firewall module
module azfwmodule 'Modules/azfw.bicep' = {
  name: 'azfw-modulename'
  params: {
    location: location
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: vnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    spokeVnetName: vnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
    spokeSubnetName: vnetmodule.outputs.OUTPUT_SPOKE_SUBNET_NAME
  }
  dependsOn: [
    vnetmodule
  ]
}
