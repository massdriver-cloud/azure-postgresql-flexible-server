locals {
  data_infrastructure = {
    ari = azurerm_postgresql_flexible_server.main.id
  }
  data_authentication = {
    username = azurerm_postgresql_flexible_server.main.administrator_login
    password = azurerm_postgresql_flexible_server.main.administrator_password
    hostname = azurerm_postgresql_flexible_server.main.fqdn
    port     = 5432
  }
  data_security = {}
}

resource "massdriver_artifact" "authentication" {
  field                = "authentication"
  provider_resource_id = azurerm_postgresql_flexible_server.main.id
  type                 = "postgresql-authentication"
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
