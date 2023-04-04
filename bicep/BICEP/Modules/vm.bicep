// Virtual Machine
param location string
param spokeVnetName string
param vmSubnetName string
param vmNumber int = 1
param zonenumber string
@secure()
param secretVmadminpassword string

// Tag values
var TAG_VALUE = {
  CostCenterNumber: '10181378'
  CreateDate: '2023/03/23'
  Location: 'japaneast'
  Owner: 'akkoike'
  }

 // VM variables
var VM_NAME = 'vm${vmNumber}'
var VM_MAIN_NAME = '${VM_NAME}-poc-main-stag-001'
var ADMIN_USERNAME = 'azureuser'
var ADMIN_PASSWORD = 'P@ssword1234'
var VM_SIZE = 'Standard_D2s_v3'
var VM_IMAGE_PUBLISHER = 'Canonical'
var VM_IMAGE_OFFER = 'UbuntuServer'
var VM_IMAGE_SKU = '18.04-LTS'
var VM_IMAGE_VERSION = 'latest'
var VM_NIC_NAME = 'nic-poc-${VM_NAME}-stag-001'
var VM_MANAGED_DISK_REDUNDANCY = 'Standard_LRS'
var VM_OS_DISK_NAME = 'osdisk-poc-${VM_NAME}-stag-001'
var VM_DATA_DISK_NAME = 'datadisk-poc-${VM_NAME}-stag-001'
var VM_DATA_DISK_SIZE = 1023
var VM_DATA_DISK_CACHING = 'ReadOnly'

// Reference the existing Spoke Subnet
resource existingspokevnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: spokeVnetName
  resource existingvmsubnet 'subnets' existing = {
    name: vmSubnetName
  }
}

//Deploy nic
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: VM_NIC_NAME
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: existingspokevnet::existingvmsubnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

//Deploy vm
resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: VM_MAIN_NAME
  location: location
  tags:TAG_VALUE
  zones: [ zonenumber ]
  properties:{
    hardwareProfile: {
      vmSize: VM_SIZE
    }
    storageProfile: {
      imageReference: {
        publisher: VM_IMAGE_PUBLISHER
        offer: VM_IMAGE_OFFER
        sku: VM_IMAGE_SKU
        version: VM_IMAGE_VERSION
      }
      osDisk: {
        name: VM_OS_DISK_NAME
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: VM_MANAGED_DISK_REDUNDANCY
        }
        diskSizeGB: 30
      }
      dataDisks: [
        {
          name: VM_DATA_DISK_NAME
          createOption: 'Empty'
          caching: VM_DATA_DISK_CACHING
          diskSizeGB: VM_DATA_DISK_SIZE
          lun: 0
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile:{
      computerName: VM_MAIN_NAME
      adminUsername: ADMIN_USERNAME
      adminPassword: secretVmadminpassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
  }
}

//Deploy vm extension DependencyAgent
resource vmExtensionDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: '${VM_NAME}-DependencyAgent'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
    settings: {
      enableAMA: true
    }
    protectedSettings: {}
  }
}

//Deploy vm extension AzureMonitorForLinux
resource vmExtensionAzureMonitorForLinux 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: '${VM_NAME}AzureMonitorForLinux'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
  }
}
/*
// Deploy vm extension linuxDiagnostic
resource vmExtensionLinuxDiagnostic 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: '${VM_NAME}LinuxDiagnostic'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'LinuxDiagnostic'
    typeHandlerVersion: '3.0'
    autoUpgradeMinorVersion: true
  }
}
*/

output OUTPUT_VM_NAME string = vm.name
output OUTPUT_NIC_NAME string = nic.name
