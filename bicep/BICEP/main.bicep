/*
  Main Template
  Please esecute from Visual Studio Code (https://azure.microsoft.com/ja-jp/products/visual-studio-code)

      -> mouse over the main.bicep file
            right click -> Deploy bicep file... -> Enter
            select your subscription and resource group
            (no need to select parameters.json file)
            This template will deploy the following resources:
                - Log Analytics Workspace
                - Hub vNET
                - Azure Firewall
                - Spoke vNET
                - Peering Hub vNET to Spoke vNET
*/

// Global variables
param location string = resourceGroup().location

// Log Analytics Workspace module
module loganalyticsmodule 'Modules/law.bicep' = {
  name: 'law-modulename'
  params: {
    location: location
  }
}

// Hub vNET module
module hubvnetmodule 'Modules/vnet-hub.bicep' = {
  name: 'hubvnet-modulename'
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
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
  }
  dependsOn: [
    hubvnetmodule
  ]
}

// Spoke-vNET module
module spokevnetmodule 'Modules/vnet-spoke.bicep' = {
  name: 'spokevnet-modulename'
  params: {
    location: location
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    azureFirewallName: azfwmodule.outputs.OUTPUT_AZFW_NAME
  }
  dependsOn: [
    azfwmodule
  ]
}

// Peering Hub-vNET to Spoke-vNET module
module peeringmodule 'Modules/vnetpeering.bicep' = {
  name: 'peering-modulename'
  params: {
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    spokeVnetName: spokevnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
  }
  dependsOn: [
    hubvnetmodule
    spokevnetmodule
  ]
}
