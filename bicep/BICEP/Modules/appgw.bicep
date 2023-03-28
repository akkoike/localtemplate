// Application Gateway
param location string
param hubVnetName string
param spokeVnetName string
//param spokeSubnetName string
//param spokeSubnetAddressPrefix string
param logAnalyticsWorkspaceName string
param principalId string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// AppGW variables
var APPGW_NAME = 'appgw-poc-main-stag-001'
var APPGW_PIP_NAME = 'pip-poc-appgw-stag-001'
var APPGW_FRONTEND_IP_CONFIG_NAME = 'frontip-poc-appgw-stag-001'
var APPGW_FRONTEND_PORT_NAME = 'frontport-poc-appgw-stag-001'
var APPGW_IP_CONFIG_NAME = 'ipconfig-poc-appgw-stag-001'
var APPGW_BACKEND_POOL_NAME = 'backendpool-poc-appgw-stag-001'
var APPGW_BACKEND_HTTP_SETTINGS_NAME = 'backendhttpsettings-poc-appgw-stag-001'
var APPGW_HTTP_LISTENER_NAME = 'httplistener-poc-appgw-stag-001'
var WAF_POLICY_NAME = 'wafpolicy-poc-appgw-stag-001'

// Reference to the hub-vnet
resource existinghubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetName
}

// Reference to the spoke-vnet
resource existingspokeVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: spokeVnetName
}

// Reference to the log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

// RBAC Configuration
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  //scope: subscription()
  // Owner
  //name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  // Contributer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // Reader
  //name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// RBAC assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appgw.id, principalId, contributorRoleDefinition.id)
  scope: appgw
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}

// Deploy public ip address
resource publicIp 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: APPGW_PIP_NAME
  location: location
  tags: TAG_VALUE
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Deploy Waf Policy
resource wafpolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-05-01' = {
  name: WAF_POLICY_NAME
  location: location
  tags: TAG_VALUE
  properties: {
    customRules: [
      {
        name: 'CustRule01'
        priority: 100
        ruleType: 'MatchRule'
        action: 'Log'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: true
            matchValues: [
              '10.10.10.0/24'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 128
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
        }
      ]
    }
  }
}
        

// Deploy Application Gateway
resource appgw 'Microsoft.Network/applicationGateways@2020-05-01' = {
  name: APPGW_NAME
  location: location
  tags: TAG_VALUE
  properties: {
  sku: {
    name: 'WAF_v2'
    //name: 'Standard_waf_v2'
    tier: 'WAF_v2'
    capacity: 2
  }
  gatewayIPConfigurations: [
     {
       name: APPGW_IP_CONFIG_NAME
       properties: {
         subnet: {
           id: existinghubVnet.properties.subnets[3].id
         }
       }
     }
  ]
  frontendIPConfigurations: [
    {
      name: APPGW_FRONTEND_IP_CONFIG_NAME
      properties: {
        privateIPAllocationMethod: 'Dynamic'
        publicIPAddress: {
          id: publicIp.id
        }
      }
    }
  ]
  frontendPorts: [
    {
      name: APPGW_FRONTEND_PORT_NAME
      properties: {
        port: 80
      }
    }
  ]
  backendAddressPools: [
    {
      name: APPGW_BACKEND_POOL_NAME
      properties: {
        /*
        backendAddresses: [
          {
            // please set your backend private ip address of your VM
            ipAddress: 'aaa'
          }
          {
            // please set your backend private ip address of your VM
            ipAddress: 'bbb'
          }
        ]
        */
      }
    }
  ]
  backendHttpSettingsCollection: [
    {
      name: APPGW_BACKEND_HTTP_SETTINGS_NAME
      properties: {
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Disabled'
        pickHostNameFromBackendAddress: false
        requestTimeout: 30
      }
    }
  ]
  httpListeners: [
    {
      name: APPGW_HTTP_LISTENER_NAME
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', APPGW_NAME, APPGW_FRONTEND_IP_CONFIG_NAME)
        }
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', APPGW_NAME, APPGW_FRONTEND_PORT_NAME)
        }
        protocol: 'Http'
        requireServerNameIndication: false
      }
    }
  ]
  requestRoutingRules: [
    {
      name: 'rule1'
      properties: {
        ruleType: 'Basic'
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', APPGW_NAME, APPGW_HTTP_LISTENER_NAME)
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', APPGW_NAME, APPGW_BACKEND_POOL_NAME)
        }
        backendHttpSettings: {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', APPGW_NAME, APPGW_BACKEND_HTTP_SETTINGS_NAME)
        }
      }
    }
  ]
  enableHttp2: false
  webApplicationFirewallConfiguration: {
    enabled: true
    firewallMode: 'prevention'
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.1'
    requestBodyCheck: true
    maxRequestBodySizeInKb: 128
    fileUploadLimitInMb: 128
  }
  firewallPolicy: {
    id: wafpolicy.id
  }

  }
}

// Deploy diagnostic settings
resource diagnosticappgw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: APPGW_NAME
  scope: appgw
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
