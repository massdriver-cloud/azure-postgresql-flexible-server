locals {
  data_infrastructure = {
    ari = azurerm_postgresql_flexible_server.main.id
  }
  data_authentication = {
    username = azurerm_postgresql_flexible_server.main.administrator_login
    password = azurerm_postgresql_flexible_server.main.administrator_password
    hostname = azurerm_postgresql_flexible_server.main.fqdn
    port     = 5432
    # PgBouncer uses port 6432 of the database server.
    # Do we expose this port as well or swap to the port?
    #
    # MSFT Docs:
    # When enabled, PgBouncer runs on port 6432 on your database server.
    # You can change your application’s database connection configuration to use the same host name,
    # but change the port to 6432 to start using PgBouncer and benefit from improved idle connection scaling.
  }
  data_security = {
  }
}

resource "massdriver_artifact" "authentication" {
  field                = "authentication"
  provider_resource_id = azurerm_postgresql_flexible_server.main.id
  name                 = "PostgreSQL Server ${var.md_metadata.name_prefix} (${azurerm_postgresql_flexible_server.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = local.data_infrastructure
        authentication = local.data_authentication
        security       = local.data_security
      }
      specs = {
        rdbms = {
          engine  = "PostgreSQL"
          version = azurerm_postgresql_flexible_server.main.version
        }
      }
    }
  )
}
