// Microsoft Defender for Cloud Policy Assignments
// This template creates policy assignments that are automatically deployed when enabling Defender for Cloud paid plans

targetScope = 'subscription'

@description('Resource Group name where policies will be assigned')
param resourceGroupName string

@description('Location for resources')
param location string = 'japaneast'

@description('Environment suffix')
param environmentSuffix string = 'prod'

@description('Enable VM protection policies')
param enableVmProtection bool = true

@description('Enable Storage protection policies')
param enableStorageProtection bool = true

@description('Enable SQL protection policies')
param enableSqlProtection bool = true

@description('Enable Container protection policies')
param enableContainerProtection bool = true

@description('Enable Key Vault protection policies')
param enableKeyVaultProtection bool = true

@description('Enable App Service protection policies')
param enableAppServiceProtection bool = true

// Reference to existing resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

// Policy Assignment: Enable VM vulnerability assessment
resource vmVulnerabilityAssessmentPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableVmProtection) {
  name: 'enable-vm-vulnerability-assessment-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure machines to receive a vulnerability assessment provider'
    description: 'Configure machines to automatically install a vulnerability assessment provider in order to identify software vulnerabilities.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/13ce0167-8ca6-4048-8e6b-f996402e3c1b'
    parameters: {
      vaType: {
        value: 'mdeTvm'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Azure Defender for Storage
resource storageDefenderPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableStorageProtection) {
  name: 'enable-defender-for-storage-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Azure Defender for Storage to be enabled'
    description: 'Enable Azure Defender for Storage on your subscription to detect unusual and potentially harmful attempts to access or exploit your storage accounts.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3'
    parameters: {
      effect: {
        value: 'DeployIfNotExists'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Azure Defender for SQL servers
resource sqlDefenderPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableSqlProtection) {
  name: 'enable-defender-for-sql-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Azure Defender for SQL servers on machines to be enabled'
    description: 'Enable Azure Defender for SQL servers on machines to protect SQL servers running on machines.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/50ea7265-7d8c-429e-9a7d-ca1f410191c3'
    parameters: {
      effect: {
        value: 'DeployIfNotExists'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Azure Defender for Containers
resource containerDefenderPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableContainerProtection) {
  name: 'enable-defender-for-containers-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Azure Defender for Containers to be enabled'
    description: 'Enable Azure Defender for Containers to provide security insights for container workloads.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f'
    parameters: {
      effect: {
        value: 'DeployIfNotExists'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Azure Defender for Key Vault
resource keyVaultDefenderPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableKeyVaultProtection) {
  name: 'enable-defender-for-keyvault-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Azure Defender for Key Vault to be enabled'
    description: 'Enable Azure Defender for Key Vault to protect your key vaults from advanced threats.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f725891-01c0-420a-9059-4fa46cb770b7'
    parameters: {
      effect: {
        value: 'DeployIfNotExists'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Azure Defender for App Service
resource appServiceDefenderPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableAppServiceProtection) {
  name: 'enable-defender-for-appservice-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Azure Defender for App Service to be enabled'
    description: 'Enable Azure Defender for App Service to protect your web applications from advanced threats.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d'
    parameters: {
      effect: {
        value: 'DeployIfNotExists'
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable log analytics agent on VMs
resource logAnalyticsAgentPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = if (enableVmProtection) {
  name: 'enable-log-analytics-agent-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Configure Log Analytics agent to be enabled on virtual machines'
    description: 'Configure machines to automatically install the Log Analytics agent for Azure Security Center.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a4fe33eb-e377-4efb-ab31-0784311bc499'
    parameters: {
      logAnalytics: {
        value: ''
      }
    }
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Policy Assignment: Enable Microsoft Defender for Cloud Apps connector
resource mcasConnectorPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = {
  name: 'enable-mcas-connector-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Enable Microsoft Defender for Cloud Apps integration'
    description: 'Enable the Microsoft Defender for Cloud Apps connector to provide cloud app security insights.'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/89099bee-89e0-4b26-a5f4-165451757743'
    parameters: {}
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
}

// Policy Assignment: Enable security configurations monitoring
resource securityConfigPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = {
  name: 'enable-security-config-monitoring-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Monitor OS vulnerabilities in Azure Security Center'
    description: 'Monitor OS vulnerabilities in Azure Security Center'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e1e5fd5d-3e4c-4ce1-8661-7d1873ae6b15'
    parameters: {}
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
}

// Policy Assignment: Enable network security monitoring
resource networkSecurityPolicy 'Microsoft.Authorization/policyAssignments@2025-01-01' = {
  name: 'enable-network-security-monitoring-${environmentSuffix}'
  location: location
  properties: {
    displayName: 'Monitor network security groups in Azure Security Center'
    description: 'Monitor network security groups in Azure Security Center'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f9be5368-9bf5-4b84-9e0a-7850da98bb46'
    parameters: {}
    metadata: {
      category: 'Security Center'
      assignedBy: 'Microsoft Defender for Cloud'
    }
    enforcementMode: 'Default'
  }
}

// Outputs
output policyAssignments array = [
  {
    name: vmVulnerabilityAssessmentPolicy.name
    id: vmVulnerabilityAssessmentPolicy.id
    enabled: enableVmProtection
  }
  {
    name: storageDefenderPolicy.name
    id: storageDefenderPolicy.id
    enabled: enableStorageProtection
  }
  {
    name: sqlDefenderPolicy.name
    id: sqlDefenderPolicy.id
    enabled: enableSqlProtection
  }
  {
    name: containerDefenderPolicy.name
    id: containerDefenderPolicy.id
    enabled: enableContainerProtection
  }
  {
    name: keyVaultDefenderPolicy.name
    id: keyVaultDefenderPolicy.id
    enabled: enableKeyVaultProtection
  }
  {
    name: appServiceDefenderPolicy.name
    id: appServiceDefenderPolicy.id
    enabled: enableAppServiceProtection
  }
]

output resourceGroupName string = resourceGroup.name
output location string = location
