param Location string
param VaultName string
param BackupPolicyName string
param RetentionDays int
param Tags object
param VmIds array

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2024-04-01' = {
  name: VaultName
  location: Location
  tags: Tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-01' = {
  parent: recoveryServicesVault
  name: BackupPolicyName
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2024-01-01T02:00:00Z'
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2024-01-01T02:00:00Z'
        ]
        retentionDuration: {
          count: RetentionDays
          durationType: 'Days'
        }
      }
    }
    timeZone: 'Tokyo Standard Time'
  }
}

resource backupProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2024-04-01' = [for (vmId, i) in VmIds: {
  name: '${VaultName}/Azure/iaasvmcontainer;iaasvmcontainerv2;${split(vmId, '/')[4]};${split(vmId, '/')[8]}/vm;iaasvmcontainerv2;${split(vmId, '/')[4]};${split(vmId, '/')[8]}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: backupPolicy.id
    sourceResourceId: vmId
  }
}]

output VaultId string = recoveryServicesVault.id
output BackupPolicyId string = backupPolicy.id
