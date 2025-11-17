param Location string
param VmNamePrefix string
param VmSize string
param AdminUsername string
@secure()
param AdminPassword string
param SubnetId string
param OsImagePublisher string
param OsImageOffer string
param OsImageSku string
param OsImageVersion string
param InstanceCount int
param Tags object
param ManagedIdentityId string

var AvailabilityZones = [
  '1'
  '2'
]

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-11-01' = [for i in range(0, InstanceCount): {
  name: '${VmNamePrefix}-nic-${i + 1}'
  location: Location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: SubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = [for i in range(0, InstanceCount): {
  name: '${VmNamePrefix}-${i + 1}'
  location: Location
  tags: Tags
  zones: [
    AvailabilityZones[i % length(AvailabilityZones)]
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentityId}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    storageProfile: {
      imageReference: {
        publisher: OsImagePublisher
        offer: OsImageOffer
        sku: OsImageSku
        version: OsImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 128
      }
    }
    osProfile: {
      computerName: '${VmNamePrefix}-${i + 1}'
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
  dependsOn: [
    networkInterface
  ]
}]

resource azureMonitorAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = [for i in range(0, InstanceCount): {
  parent: virtualMachine[i]
  name: 'AzureMonitorLinuxAgent'
  location: Location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}]

output VmIds array = [for i in range(0, InstanceCount): virtualMachine[i].id]
output VmNames array = [for i in range(0, InstanceCount): virtualMachine[i].name]
