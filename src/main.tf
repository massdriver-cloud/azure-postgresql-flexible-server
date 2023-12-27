locals {
  mode = cache_store.version.value != var.database.postgres_version ? "Update" : var.database.mode
}

resource "random_password" "master_password" {
  length  = 10
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.azure_virtual_network.specs.azure.region
  tags     = var.md_metadata.default_tags
}

resource "azurerm_private_dns_zone" "main" {
  name                = "${var.md_metadata.name_prefix}-dns.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.md_metadata.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = var.md_metadata.name_prefix
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.azure_virtual_network.data.infrastructure.id
  tags                  = var.md_metadata.default_tags
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                              = var.md_metadata.name_prefix
  resource_group_name               = azurerm_resource_group.main.name
  location                          = var.azure_virtual_network.specs.azure.region
  version                           = var.database.postgres_version
  storage_mb                        = var.database.storage_mb
  sku_name                          = var.database.sku_name
  create_mode                       = local.mode
  source_server_id                  = var.database.mode == "Replica" || var.database.mode == "PointInTimeRestore" ? var.database.source_server : null
  point_in_time_restore_time_in_utc = var.database.mode == "PointInTimeRestore" ? var.database.restore_time : null
  administrator_login               = var.database.username
  administrator_password            = random_password.master_password.result
  backup_retention_days             = var.backup.backup_retention_days
  geo_redundant_backup_enabled      = var.backup.geo_redundant_backup
  delegated_subnet_id               = azurerm_subnet.main.id
  private_dns_zone_id               = azurerm_private_dns_zone.main.id
  tags                              = var.md_metadata.default_tags

  dynamic "high_availability" {
    for_each = var.database.high_availability ? toset(["enabled"]) : toset([])
    content {
      mode = "ZoneRedundant"
    }
  }
  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.main
  ]
}

resource "cache_store" "version" {
  value = var.database.postgres_version
}
