/*
  Main Template
  Please execute from Visual Studio Code (https://azure.microsoft.com/ja-jp/products/visual-studio-code)

      At first:
        Please set your User-PrincipalID(ObjectID) to ./Modules/userparam.json file because of using RBAC.
        -> Check your USER Object ID on Azure Active Directory blade by using Azure Portal.
      At second:
         mouse over the main.bicep file
         right click -> Deploy bicep file... -> Enter
         select your subscription and resource group
         (no need to select parameters.json file)
         This template will deploy the following resources:
            - Log Analytics Workspace
            - Hub vNET
            - Azure Firewall
            - Spoke vNET
            - Peering Hub vNET to Spoke vNET
            - Application Gateway
            - Azure Bastion
            - Azure Monitor Private Link Scope
            - RBAC for all resources (Role Assignment)

*/

// Global variables
param location string = resourceGroup().location

// Log Analytics Workspace module
module loganalyticsmodule 'Modules/law.bicep' = {
  name: 'law-modulename'
  params: {
    location: location
}

// Hub vNET module
module hubvnetmodule 'Modules/vnet-hub.bicep' = {
  name: 'hubvnet-modulename'
  params: {
    location: location
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
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    azfwSubnetName: hubvnetmodule.outputs.OUTPUT_AZFW_HUB_SUBNET_NAME
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

// Application Gateway module
module appgwmodule 'Modules/appgw.bicep' = {
  name: 'appgw-modulename'
  params: {
    location: location
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    appgwSubnetName: hubvnetmodule.outputs.OUTPUT_APPGW_HUB_SUBNET_NAME
    spokeVnetName: spokevnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
  }
  dependsOn: [
    hubvnetmodule
  ]
}

// Bastion module
module bastionmodule 'Modules/bastion.bicep' = {
  name: 'bastion-modulename'
  params: {
    location: location
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    bastionSubnetName: hubvnetmodule.outputs.OUTPUT_BASTION_HUB_SUBNET_NAME
  }
  dependsOn: [
    hubvnetmodule
  ]
}

// Azure Monitor Private Link Scope module
module amplsmodule 'Modules/ampls.bicep' = {
  name: 'ampls-modulename'
  params: {
    location: location
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    dnsSubnetName: hubvnetmodule.outputs.OUTPUT_DNS_HUB_SUBNET_NAME
  }
  dependsOn: [
    hubvnetmodule
  ]
}

// RBAC module
module rbacmodule 'Modules/rbac.bicep' = {
  name: 'rbac-modulename'
  params: {
    appgwName: appgwmodule.outputs.OUTPUT_APPGW_NAME
    azfwName: azfwmodule.outputs.OUTPUT_AZFW_NAME
    bastionName: bastionmodule.outputs.OUTPUT_BASTION_NAME
    lawName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    spokeVnetName: spokevnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
  }
  dependsOn: [
    appgwmodule
  ]
}
