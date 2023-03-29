/*
  Main Template
  Please esecute from Visual Studio Code (https://azure.microsoft.com/ja-jp/products/visual-studio-code)

      At first:
        Please set your User-PrincipalID(ObjectID) to userparam.json file.
        -> Check your Azure Active Directory User blade by using Azure Portal.
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
*/

// Global variables
param location string = resourceGroup().location
//param akkoikeObjectId string = '16a7b5e2-8152-4132-85a3-95a078139291'

var USER_OBJECT_ID = loadJsonContent('./userparam.json', 'UserObjectId001')
//param managedIdentityName string = 'MyUserManagedIdentity'

/*
// Deploy Managed IDentity (User Assigned)
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}
*/

// Log Analytics Workspace module
module loganalyticsmodule 'Modules/law.bicep' = {
  name: 'law-modulename'
  params: {
    location: location
    principalId: USER_OBJECT_ID
    /*
    managedIdentityId: managedIdentity.id
    principalId: managedIdentity.properties.principalId
    */
  }
  /*
  dependsOn: [
    managedIdentity
  ]
  */
}

// Hub vNET module
module hubvnetmodule 'Modules/vnet-hub.bicep' = {
  name: 'hubvnet-modulename'
  params: {
    location: location
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    principalId: USER_OBJECT_ID
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
    azfwSubnetName: hubvnetmodule.outputs.OUTPUT_AZFW_HUB_SUBNET_NAME
    principalId: USER_OBJECT_ID
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
    principalId: USER_OBJECT_ID
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
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    appgwSubnetName: hubvnetmodule.outputs.OUTPUT_APPGW_HUB_SUBNET_NAME
    spokeVnetName: spokevnetmodule.outputs.OUTPUT_SPOKE_VNET_NAME
    principalId: USER_OBJECT_ID
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
    logAnalyticsWorkspaceName: loganalyticsmodule.outputs.OUTPUT_LAW_NAME
    hubVnetName: hubvnetmodule.outputs.OUTPUT_HUB_VNET_NAME
    bastionSubnetName: hubvnetmodule.outputs.OUTPUT_BASTION_HUB_SUBNET_NAME
    principalId: USER_OBJECT_ID
  }
  dependsOn: [
    hubvnetmodule
  ]
}
