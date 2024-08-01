param applicationName string
param location string

param applicationKind string 
param financialTag string
param appSvcPlanId string
param hostingEnvironmentProfile string
param versionName string
param versionValue string 
param runtimeName string
param runtimeValue string 
param netFrameworkVersion string

resource WindowsWebApp 'Microsoft.Web/sites@2023-12-01' = {
  name: applicationName
  location: location
  tags: {
    financial: financialTag
  }
  kind: applicationKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    enabled: true
    hostNameSslStates: [
      {
        name: '${applicationName}.ase-rapid-dev.appserviceenvironment.us'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${applicationName}.scm.ase-rapid-dev.appserviceenvironment.us'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    siteConfig: {
      appSettings: [
        {
          name: versionName
          value: versionValue
        }
        {
          name: runtimeName
          value: runtimeValue
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: '<AzureStorageConnectionString>'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.us'
          'https://functions.ext.azure.us'
        ]
      }
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      minimumElasticInstanceCount: 0
      http20Enabled: false
      functionAppScaleLimit: 200
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      netFrameworkVersion: netFrameworkVersion
    }
    clientAffinityEnabled: true
    httpsOnly: false
    serverFarmId: appSvcPlanId
    hostingEnvironmentProfile: {
      id: hostingEnvironmentProfile
    }
    publicNetworkAccess: 'Disabled'
  }
}
resource CredentialPolicy1 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: WindowsWebApp
  name: 'scm'
  properties: {
    allow: true
  }
}
resource CredentialPolicy2 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: WindowsWebApp
  name: 'ftp'
  properties: {
    allow: false
  }
}
