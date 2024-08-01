param appServicePlanName string
param location string
param financialTag string
param skuTier string
param skuCode string
param hostingEnvironmentProfile string

resource appSvcPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: {
    financial: financialTag
  }
  kind: 'functionapp'
  properties: {
    hostingEnvironmentProfile: {
      id: hostingEnvironmentProfile
    }
    zoneRedundant: true
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 3
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
  }
  sku: {
    tier: skuTier
    name: skuCode
    size: skuCode
    family: skuCode
    capacity: 3
  }
}

output appSvcPlanId string = appSvcPlan.id
