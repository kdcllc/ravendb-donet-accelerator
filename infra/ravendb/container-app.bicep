param containerAppEnvId string

param tags object = {}

param storageName string

param volumeName string = 'ravendb-volume'

param ravendbAppName string = 'ravendb'
param location string = resourceGroup().location
param ravendbDockerImage string = 'ravendb/ravendb:6.0.105-ubuntu.22.04-x64'

resource ravendbContainerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: ravendbAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnvId
    configuration: {
      ingress: {
        additionalPortMappings: [
          {
            exposedPort: 38888
            external: false
            targetPort: 38888
          }
        ]
        external: true
        targetPort: 8080
        
      }
      registries: []
    }
    template: {
      containers: [
        {
          name: 'ravendb'
          image: ravendbDockerImage
          resources: {
            cpu: 1
            memory: '2.0Gi'
          }
          env: [
            {
              name: 'RAVEN_SETTINGS'
              value: '{}'
            }
            {
              name: 'RAVEN_Security_UnsecuredAccessAllowed'
              value: 'PublicNetwork'
            }
            {
              name: 'RAVEN_Setup_Mode'
              value: 'None'
            }
            {
              name: 'RAVEN_License_Eula_Accepted'
              value: 'true'
            }
            {
              name: 'RAVEN_ServerUrl'
              value: 'http://0.0.0.0:8080'
            }
            {
              name: 'RAVEN_ServerUrl_Tcp'
              value: 'tcp://0.0.0.0:38888'
            }
          ]
          volumeMounts: [
            {
              volumeName: volumeName
              mountPath: '/var/lib/ravendb/data'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      volumes: [
        {
          name: volumeName
          storageName:  storageName
          storageType: 'AzureFile'
          mountOptions: 'dir_mode=0777,file_mode=0777,uid=1001,gid=1001,mfsymlinks,nobrl'
        }
      ]
    }
  }
}
