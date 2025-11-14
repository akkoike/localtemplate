// Backup module
param location string
param vaultName string
param tags object
param backupPolicyName string = 'DailyBackupPolicy'
param retentionDays int = 30

resource vault 'Microsoft.RecoveryServices/vaults@2023-04-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource vaultConfig 'Microsoft.RecoveryServices/vaults/backupconfig@2023-04-01' = {
  parent: vault
  name: 'vaultconfig'
  properties: {
    storageType: 'LocallyRedundant'
    storageTypeState: 'Locked'
  }
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
  parent: vault
  name: backupPolicyName
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2024-01-01T02:00:00Z'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2024-01-01T02:00:00Z'
        ]
        retentionDuration: {
          count: retentionDays
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: 'Tokyo Standard Time'
  }
}

output vaultId string = vault.id
output vaultName string = vault.name
output backupPolicyName string = backupPolicy.name
output backupPolicyId string = backupPolicy.id
