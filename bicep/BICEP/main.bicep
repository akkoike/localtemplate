/*
  Main Template
  Please execute from Visual Studio Code (https://azure.microsoft.com/ja-jp/products/visual-studio-code)

      At first:
        Please set your User-PrincipalID(ObjectID) to ./Modules/userparam.json file because of using RBAC.
        -> Check your USER Object ID on Azure Active Directory by using Azure Portal.

      At second:
         1. Mouse over the main.bicep file
         2. Right click -> Deploy bicep file... -> Enter
         3. Select your subscription and resource group
            (no need to select parameters.json file and default location is "Japan East")
         4. Wait for a while

       This template will deploy the following resources:
            - Hub vNET
            - Azure Firewall
            - Spoke vNET
            - Peering Hub vNET to Spoke vNET
            - Application Gateway
            - Azure Bastion
            - Log Analytics Workspace
            - Azure Monitor Private Link Scope
            - RBAC for all resources (Role Assignment)
            - Diagnostic Settings for several resources

*/

// Global variables
param location string = resourceGroup().location
var currentResourceGroupName = resourceGroup().name

// Hub vNET module
module hubvnetmodule 'Modules/vnet-hub.bicep' = {
  name: 'hubvnet-modulename'
  params: {
    location: location
  }
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
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    dnsSubnetName: hubvnetmodule.outputs.OUTPUT_DNS_HUB_SUBNET_NAME
  }
  dependsOn: [
    hubvnetmodule
  ]
}

// Log Analytics Workspace module
module lawmodule 'Modules/law.bicep' = {
  name: 'law-modulename'
  params: {
    location: location
    amplsName: amplsmodule.outputs.OUTPUT_AMPLS_NAME
  }
  dependsOn: [
    amplsmodule
  ]
}

// Storage Account module
module straccmodule 'Modules/storageaccount.bicep' = {
  name: 'str-modulename'
  params: {
    location: location
  }
}

// NSG Flow Log module
module nsgflowlogmodule 'Modules/nsgflowlog.bicep' = {
  name: 'nsgflowlog-modulename'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    location: location
    currentResourceGroupName: currentResourceGroupName
    straccId: straccmodule.outputs.OUTPUT_STORAGE_ACCOUNT_NSGFLOWLOG_ID
    lawId: lawmodule.outputs.OUTPUT_LAW_ID
    nsgappgwwafName: hubvnetmodule.outputs.OUTPUT_NSG_APPGW_INBOUND_NAME
    nsgdnsName: hubvnetmodule.outputs.OUTPUT_NSG_DNS_INBOUND_NAME
    nsgspokeName: spokevnetmodule.outputs.OUTPUT_NSG_SPOKE_INBOUND_NAME
  }
  dependsOn: [
    hubvnetmodule
    appgwmodule
    spokevnetmodule
    straccmodule
    lawmodule
  ]
}


// RBAC module
module rbacmodule 'Modules/rbac.bicep' = {
  name: 'rbac-modulename'
  params: {
    appgwName: appgwmodule.outputs.OUTPUT_APPGW_NAME
    appgwpipName: appgwmodule.outputs.OUTPUT_APPGW_PIP_NAME
    appgwwafName: appgwmodule.outputs.OUTPUT_WAFPOLICY_NAME
    azfwName: azfwmodule.outputs.OUTPUT_AZFW_NAME
    azfwpipName: azfwmodule.outputs.OUTPUT_AZFW_PIP_NAME
    bastionName: bastionmodule.outputs.OUTPUT_BASTION_NAME
    bastionpipName: bastionmodule.outputs.OUTPUT_BASTION_PIP_NAME
    lawName: lawmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    spokeVnetName: spokevnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
    amplsName: amplsmodule.outputs.OUTPUT_AMPLS_NAME
    peName: amplsmodule.outputs.OUTPUT_PE_NAME
    nsgappgwwafName: hubvnetmodule.outputs.OUTPUT_NSG_APPGW_INBOUND_NAME
    nsgdnsName: hubvnetmodule.outputs.OUTPUT_NSG_DNS_INBOUND_NAME
    nsgspokeName: spokevnetmodule.outputs.OUTPUT_NSG_SPOKE_INBOUND_NAME
  }
  dependsOn: [
    appgwmodule
    bastionmodule
    lawmodule
    azfwmodule
    hubvnetmodule
    spokevnetmodule
    amplsmodule
  ]
}

// Diagnostic Settings module
module diagsettingsmodule 'Modules/diagnostic.bicep' = {
  name: 'diagsettings-modulename'
  params: {
    logAnalyticsWorkspaceName: lawmodule.outputs.OUTPUT_LAW_NAME
    appgwName: appgwmodule.outputs.OUTPUT_APPGW_NAME
    azfwName: azfwmodule.outputs.OUTPUT_AZFW_NAME
    bastionName: bastionmodule.outputs.OUTPUT_BASTION_NAME
    pipappgwName: appgwmodule.outputs.OUTPUT_APPGW_PIP_NAME
    pipazfwName: azfwmodule.outputs.OUTPUT_AZFW_PIP_NAME
    pipbastionName: bastionmodule.outputs.OUTPUT_BASTION_PIP_NAME
    nsgappgwwafName: hubvnetmodule.outputs.OUTPUT_NSG_APPGW_INBOUND_NAME
    nsgdnsName: hubvnetmodule.outputs.OUTPUT_NSG_DNS_INBOUND_NAME
    nsgspokeName: spokevnetmodule.outputs.OUTPUT_NSG_SPOKE_INBOUND_NAME
  }
  dependsOn: [
    appgwmodule
    bastionmodule
    lawmodule
    azfwmodule
    hubvnetmodule
    spokevnetmodule
    amplsmodule
  ]
}
