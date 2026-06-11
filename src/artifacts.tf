locals {
  infrastructure = {
    ari = azurerm_postgresql_flexible_server.main.id
  }
  authentication = {
    username = azurerm_postgresql_flexible_server.main.administrator_login
    password = azurerm_postgresql_flexible_server.main.administrator_password
    hostname = azurerm_postgresql_flexible_server.main.fqdn
    port     = var.addons.pgbouncer ? 6432 : 5432
    # PgBouncer uses port 6432 of the database server.
    #
    # MSFT Docs:
    # When enabled, PgBouncer runs on port 6432 on your database server.
    # You can change your application’s database connection configuration to use the same host name,
    # but change the port to 6432 to start using PgBouncer and benefit from improved idle connection scaling.
  }
  security = {
  }
}

resource "massdriver_artifact" "authentication" {
  field    = "authentication"
  name     = "PostgreSQL Server ${var.md_metadata.name_prefix} (${azurerm_postgresql_flexible_server.main.id})"
  artifact = jsonencode(
    {
      infrastructure = local.infrastructure
      authentication = local.authentication
      security       = local.security
      specs = {
        rdbms = {
          engine  = "PostgreSQL"
          version = azurerm_postgresql_flexible_server.main.version
        }
      }
    }
  )
}
