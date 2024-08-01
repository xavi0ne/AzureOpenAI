param appInsightsName string
param financialTag string

//allowed values are: 'web', 'java', 'other'//
param appType string
param appLocation string
param LogAnalyticsId string


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: appLocation
  kind: appType
  tags: {
    financial: financialTag
  }
  properties: {
    Application_Type: appType
    RetentionInDays: 90
    ImmediatePurgeDataOn30Days: true
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: LogAnalyticsId
    IngestionMode: 'LogAnalytics'
  }
}
