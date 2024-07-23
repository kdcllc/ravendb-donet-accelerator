# Agenda Manager with RavenDB and ASP.NET Core

This is a demo application for an Agenda manager (yes, a todo app) that uses ASP.NET Core and RavenDB. 

Version pinged to `6.0.105`

## Running locally

1. To get started you'll need to run a RavenDB instance using Docker with the following command:

```bash
    
    # create instance of ravendb
    docker-compose up -d ravendb

    # remove instance of ravendb
    docker-compose down ravendb
```

2. Run the project `dotnet run --project src/AgendaManager/AgendaManager.csproj` and it will create a new database called **"Productivity"** and index **Agendas**.



## Advantages to RavenDB

- The document model is a great development experience
- Fine tuning queries with indexes

## RavenDB considerations

- Remembering to create static indexes
- Those string Ids can be a challenge to work around (See `EncryptedParameter`)
- Stale results (not an issue in this sample)

## Notes

- Created using [JetBrains Rider](https://jetbrains.com/rider)
- Used JetBrains AI Assistant for some Bootstrap and JQuery stuff
- RavenDB instance is a development instance so there's no security
- Application assumes one user but could be made to support multiple users with the addition of identity.


## References

- https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2023-05-01/containerapps?pivots=deployment-language-bicep


## Thanks to

- [khalidabuhakmeh](https://github.com/khalidabuhakmeh/RavenDBAgendaManager)