param name string
param location string = resourceGroup().location
param tags object = {}

param logAnalyticsWorkspaceName string
param applicationInsightsName string = ''

param containerAppsEnvAzureFile string
param storageAccountName string
@secure()
param storageAccountKey string
param shareName string = 'databae'

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIConnectionString: applicationInsights.properties.ConnectionString
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2023-05-01/managedenvironments/storages?pivots=deployment-language-bicep
resource containerAppsEnvironmentStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: containerAppsEnvAzureFile
  parent: containerAppsEnvironment
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountKey: storageAccountKey
      accountName: storageAccountName
      shareName: shareName
    }
  }
}


output name string = containerAppsEnvironment.name
output id string = containerAppsEnvironment.id
output domain string = containerAppsEnvironment.properties.defaultDomain
output containerAppsEnvironment object = containerAppsEnvironment
