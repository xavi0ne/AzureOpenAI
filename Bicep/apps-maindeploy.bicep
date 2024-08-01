param resourceGroup string
param appServicePlanName string
param applicationName string
param location string
param financialTag string

param skuTier string
param skuCode string
param hostingEnvironmentProfileId string

param applicationKind string

param versionName string
param versionValue string
param runtimeName string
param runtimeValue string
param netFrameworkVersion string
param storageAccountName string

param appInsightsName string
//allowed values are: 'web', 'java', 'other'//
param appType string
param appLocation string
param LogAnalyticsId string


module appSvcPlan 'appSvcPlan-module.bicep' = {
  name: 'deployAppSvcPlan'
  scope: az.resourceGroup(resourceGroup)
  params: {
    appServicePlanName: appServicePlanName
    hostingEnvironmentProfile: hostingEnvironmentProfileId
    financialTag: financialTag
    location: location
    skuCode: skuCode
    skuTier: skuTier
  }
}
module windowsApp'windowsApp-module.bicep' = {
  scope: az.resourceGroup(resourceGroup)
  name: 'deployWindowsApp'
  params: {
    appSvcPlanId: appSvcPlan.outputs.appSvcPlanId
    applicationName: applicationName
    applicationKind: applicationKind
    financialTag: financialTag
    hostingEnvironmentProfile: hostingEnvironmentProfileId
    location: location
    netFrameworkVersion: netFrameworkVersion
    runtimeName: runtimeName
    runtimeValue: runtimeValue
    versionName: versionName
    versionValue: versionValue
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appSvcPlan
  ]
}

module appInsights 'module-appInsights.bicep' = {
  scope: az.resourceGroup(resourceGroup)
  name: 'deployAppInsights'
  params: {
    appInsightsName: appInsightsName
    appLocation: appLocation
    appType: appType
    financialTag: financialTag
    LogAnalyticsId: LogAnalyticsId
  }
  dependsOn: [
    windowsApp
  ]
}

output appSvcPlanId string = appSvcPlan.outputs.appSvcPlanId
