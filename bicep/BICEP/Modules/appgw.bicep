// Application Gateway
param location string
param hubVnetName string
param spokeVnetName string
param spokeSubnetName string
param spokeSubnetAddressPrefix string
param logAnalyticsWorkspaceName string

// Tag values
var TAG_VALUE = {
CostCenterNumber: '10181378'
CreateDate: '2023/03/23'
Location: 'japaneast'
Owner: 'akkoike'
}

// AppGW variables
var APPGW_NAME = 'appgw-poc-main-stag-001'
