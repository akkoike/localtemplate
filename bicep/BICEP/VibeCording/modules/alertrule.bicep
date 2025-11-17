param ActionGroupName string
param AdminEmail string
param VmIds array
param Tags object

resource actionGroup 'Microsoft.Insights/actionGroups@2023-09-01-preview' = {
  name: ActionGroupName
  location: 'Global'
  tags: Tags
  properties: {
    groupShortName: substring(ActionGroupName, 0, min(12, length(ActionGroupName)))
    enabled: true
    emailReceivers: [
      {
        name: 'AdminEmail'
        emailAddress: AdminEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource cpuAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vmId, i) in VmIds: {
  name: 'alert-cpu-${split(vmId, '/')[8]}'
  location: 'Global'
  tags: Tags
  properties: {
    description: 'Alert when CPU usage exceeds 80% for 5 minutes'
    severity: 2
    enabled: true
    scopes: [
      vmId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighCpuUsage'
          metricName: 'Percentage CPU'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}]

resource memoryAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vmId, i) in VmIds: {
  name: 'alert-memory-${split(vmId, '/')[8]}'
  location: 'Global'
  tags: Tags
  properties: {
    description: 'Alert when memory usage exceeds 75% for 5 minutes'
    severity: 2
    enabled: true
    scopes: [
      vmId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighMemoryUsage'
          metricName: 'Available Memory Bytes'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: 'LessThan'
          threshold: 1073741824
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}]

resource networkInAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vmId, i) in VmIds: {
  name: 'alert-netin-${split(vmId, '/')[8]}'
  location: 'Global'
  tags: Tags
  properties: {
    description: 'Alert when network in exceeds 300MB in 1 minute'
    severity: 2
    enabled: true
    scopes: [
      vmId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT1M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighNetworkIn'
          metricName: 'Network In Total'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: 'GreaterThan'
          threshold: 314572800
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}]

resource networkOutAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vmId, i) in VmIds: {
  name: 'alert-netout-${split(vmId, '/')[8]}'
  location: 'Global'
  tags: Tags
  properties: {
    description: 'Alert when network out exceeds 300MB in 1 minute'
    severity: 2
    enabled: true
    scopes: [
      vmId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT1M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighNetworkOut'
          metricName: 'Network Out Total'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: 'GreaterThan'
          threshold: 314572800
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}]

output ActionGroupId string = actionGroup.id
