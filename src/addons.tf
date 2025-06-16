resource "azurerm_postgresql_flexible_server_configuration" "pgbouncer" {
  count     = var.addons.pgbouncer ? 1 : 0
  name      = "pgbouncer.enabled"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "true"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  count     = length(try(var.addons.extensions, [])) > 0 ? 1 : 0
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = join(",", try(var.addons.extensions, []))
}