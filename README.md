# RavenDb .NET Core Accelerator for POC Projects with Azure Container Apps

[![GitHub](https://img.shields.io/github/license/kdcllc/ravendb-donet-accelerator.svg)](https://github.com/kdcllc/ravendb-donet-accelerator/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/kdcllc/ravendb-donet-accelerator.svg?style=social)](https://github.com/kdcllc/ravendb-donet-accelerator/stargazers)

This repository provides a complete accelerator for Proof of Concept (POC) projects using RavenDB and ASP.NET Core, deployed with Azure Container Apps.

![I stand with Israel](./images/IStandWithIsrael.png)

## Overview

This accelerator is designed to help you quickly set up a RavenDB-backed ASP.NET Core application, ideal for POC projects. It includes:

- A sample Agenda Manager application (a simple todo app)
- Integration with RavenDB for data storage
- Deployment scripts for Azure Container Apps

> **Note:** This accelerator is designed specifically for Proof of Concept (POC) projects and may not be suitable for production use.

## Hire me

Please send [email](mailto:kingdavidconsulting@gmail.com) if you consider to **hire me**.

[![buymeacoffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/vyve0og)

## Give a Star! :star

If you like or are using this project to learn or start your solution, please give it a star. Thanks!

## Prerequisites

- [.NET SDK 8.0](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker](https://www.docker.com/get-started)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

## Running Locally

1. **Start RavenDB using Docker:**

    ```bash
    # Create instance of RavenDB
    docker-compose up -d ravendb

    # Remove instance of RavenDB
    docker-compose down ravendb
    ```

2. **Run the project:**

    ```bash
    dotnet run --project src/AgendaManager/AgendaManager.csproj
    ```

    This will create a new database called **"Productivity"** and an index **Agendas**.

## Deploying to Azure

1. **Install Azure Developer CLI:**

    Download and install [`azd cli`](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd).

2. **Deploy using `azd up`:**

    Run `azd up` and follow the steps to create Azure Resources.

### Azure Resources Created

| Resource Type                | Resource Name                                      |
|------------------------------|----------------------------------------------------|
| Resource Group               | `${environmentName}-rg`                            |
| Log Analytics Workspace      | `${abbrs.operationalInsightsWorkspaces}${resourceToken}` |
| Application Insights         | `${abbrs.insightsComponents}${resourceToken}`      |
| Container Registry           | `${abbrs.containerRegistryRegistries}${resourceToken}` |
| Key Vault                    | `${abbrs.keyVaultVaults}${resourceToken}`          |
| Storage Account              | `${abbrs.storageStorageAccounts}${resourceToken}`  |
| Container Apps Environment   | `${abbrs.appManagedEnvironments}${resourceToken}`  |
| RavenDB Container App        | `ravendb`                                          |
| Agenda Manager Container App | `${abbrs.appContainerApps}agendamanage-${resourceToken}` |

### Post deployment steps to secure RavenDb

Navigate to Ingress section of `ravendb` Azure Container App in the Azure Container Environment and:

1. Select -> 'Allow traffic from IPs configured below, deny all other traffic'
2. Click -> 'Add the app's outbound IP address'
3. Add any other IP address in order to have access to RavenDb.
![ip restriction mode](./images/ip-restrictions-mode.png)

## Advantages of Using RavenDB

- **Document Model:** Provides a great development experience.
- **Indexing:** Allows fine-tuning of queries with indexes.

## Considerations for RavenDB

- **Static Indexes:** Remember to create static indexes.
- **String IDs:** Can be challenging to work with (see `EncryptedParameter`).
- **Stale Results:** Not an issue in this sample.

## Notes

- The RavenDB instance is a development instance with no security.
- The application assumes a single user but can be extended to support multiple users with identity management.

## References

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2023-05-01/containerapps?pivots=deployment-language-bicep)
- [Connect applications in Azure Container Apps: Call a container app by name](https://learn.microsoft.com/en-us/azure/container-apps/connect-apps?tabs=bash#call-a-container-app-by-name)

## Acknowledgements

- Thanks to [khalidabuhakmeh](https://github.com/khalidabuhakmeh/RavenDBAgendaManager) for the original inspiration.
