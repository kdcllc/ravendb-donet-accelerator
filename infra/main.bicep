targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the ravehdb container app application')
param ravendbAppName string = 'ravendb'

param agendaManagerExists bool
@secure()
param agendaManagerDefinition object

@description('Id of the user or app to assign application roles')
param principalId string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${environmentName}-rg'
  location: location
  tags: tags
}

module monitoring './shared/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
  scope: rg
}

module dashboard './shared/dashboard-web.bicep' = {
  name: 'dashboard'
  params: {
    name: '${abbrs.portalDashboards}${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    location: location
    tags: tags
  }
  scope: rg
}

module registry './shared/registry.bicep' = {
  name: 'registry'
  params: {
    location: location
    tags: tags
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
  scope: rg
}

module keyVault './shared/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tags: tags
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    principalId: principalId
  }
  scope: rg
}

module storage 'shared/storage.bicep' = {
  name: '${abbrs.storageStorageAccounts}${resourceToken}'
  params: {
    location: location
    tags: tags
    storageName: '${abbrs.storageStorageAccounts}${resourceToken}'
    fileShareName: 'database'
  }
  scope: rg
}

module appsEnv './shared/apps-env.bicep' = {
  name: 'apps-env'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
    storageAccountKey: storage.outputs.storageAccountKey
    storageAccountName: storage.outputs.storageAccountName
    shareName: 'database'
    containerAppsEnvAzureFile: 'ravendbstorage'
  }
  scope: rg
}

module ravendb './ravendb/container-app.bicep' = {
  name: 'ravendb'
  params: {
    location: location
    tags: tags
    ravendbAppName: ravendbAppName
    containerAppEnvId: appsEnv.outputs.id
    ravendbDockerImage: 'ravendb/ravendb:6.0.105-ubuntu.22.04-x64'
    storageName: 'ravendbstorage'
    volumeName: 'ravendb-volume'
  }
  scope: rg
}

module agendaManager './app/AgendaManager.bicep' = {
  name: 'AgendaManager'
  params: {
    name: '${abbrs.appContainerApps}agendamanage-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}agendamanage-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: agendaManagerExists
    appDefinition: agendaManagerDefinition
    ravenDbConnectinString: 'http://${ravendbAppName}'
  }
  scope: rg
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.loginServer
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
