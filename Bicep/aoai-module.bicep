param AzureOpenAiName string
param AzureOpenAi_PrivateEndpointName string
param location string
param sku object = {
  name: 'S0'
}
param tag string
param deploymentModelVersion string
param deploymentModelname string
param deploymentModelCapacity string
param skuType string

param subnetID string
param AzureOpenAi_IP string
param resourceGroup string
param subscriptionId string


var logAnalyticsId = ''
var LogCategories = [
  'Audit'
  'RequestResponse'
  'Trace'
]
var MetricCategories = [
  'AllMetrics'
]
var openAiLogs = [for category in LogCategories: {
  category: category
  enabled: true
}]
var openAiMetrics = [for category in MetricCategories: {
  category: category
  enabled: true
}]
var AzureOpenAi_PvDnsZoneID = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.us'
var eventHubName = ''
var eventHubID = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.EventHub/namespaces/${eventHubName}/authorizationRules/RootManageSharedAccessKey'

resource AzureOpenAi 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: AzureOpenAiName
  location: location
  sku: sku
  kind: 'OpenAI'
   identity: {
    type: 'SystemAssigned'
   }
   tags: {
    financial: tag
   }
   properties: {
    encryption: {
      keySource: 'Microsoft.CognitiveServices'
    }
    customSubDomainName: AzureOpenAiName
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: []
      ipRules: []
    }
   }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: AzureOpenAi_PrivateEndpointName
  location: location
  tags: {
    financial: tag
  }
  properties: {
    subnet: {
      id: subnetID
    }
    privateLinkServiceConnections: [
      {
        name: AzureOpenAi_PrivateEndpointName
        properties: {
          privateLinkServiceId: AzureOpenAi.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: AzureOpenAi_PrivateEndpointName
        properties: {
          
          groupId: 'account'
          
          memberName: 'default'
            
          privateIPAddress: AzureOpenAi_IP
        }
      }  
    ]
  }
}
resource pvtDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${AzureOpenAi_PrivateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: AzureOpenAi_PvDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: AzureOpenAi
  name: '${AzureOpenAiName}-ds'
  properties: {
    workspaceId: logAnalyticsId
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHubName
    logs: openAiLogs
    metrics: openAiMetrics
  }
  dependsOn: [
    pvtDnsGroup
  ]
}

resource AzureOpenAiModels 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview'  = {
  name: deploymentModelname
  parent: AzureOpenAi
  sku: {
    name: skuType
    capacity: deploymentModelCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: deploymentModelname
      version: deploymentModelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  dependsOn: [
    diagnostics
  ]
}
