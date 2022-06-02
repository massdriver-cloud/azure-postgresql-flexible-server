locals {
  size_map = {
    "B1ms (1 vCore, 2 GiB memory, 640 max iops)"       = "B_Standard_B1ms"
    "B2s (2 vCores, 4 GiB memory, 1280 max iops)"      = "B_Standard_B2s"
    "D2s (2 vCores, 8 GiB memory, 3200 max iops)"      = "GP_Standard_D2s_v3"
    "D4s (4 vCores, 16 GiB memory, 6400 max iops)"     = "GP_Standard_D4s_v3"
    "D8s (8 vCores, 32 GiB memory, 12800 max iops)"    = "GP_Standard_D8s_v3"
    "D16s (16 vCores, 64 GiB memory, 18000 max iops)"  = "GP_Standard_D16s_v3"
    "D32s (32 vCores, 128 GiB memory, 18000 max iops)" = "GP_Standard_D32s_v3"
    "D48s (48 vCores, 192 GiB memory, 18000 max iops)" = "GP_Standard_D48s_v3"
    "D64s (64 vCores, 256 GiB memory, 18000 max iops)" = "GP_Standard_D64s_v3"
    "E2s (2 vCores, 16 GiB memory, 3200 max iops)"     = "MO_Standard_E2s_v3"
    "E4s (4 vCores, 32 GiB memory, 6400 max iops)"     = "MO_Standard_E4s_v3"
    "E8s (8 vCores, 64 GiB memory, 12800 max iops)"    = "MO_Standard_E8s_v3"
    "E16s (16 vCores, 128 GiB memory, 18000 max iops)" = "MO_Standard_E16s_v3"
    "E32s (32 vCores, 256 GiB memory, 18000 max iops)" = "MO_Standard_E32s_v3"
    "E48s (48 vCores, 384 GiB memory, 18000 max iops)" = "MO_Standard_E48s_v3"
    "E64s (64 vCores, 432 GiB memory, 18000 max iops)" = "MO_Standard_E64s_v3"
  }
  sku = lookup(local.size_map, var.size, "")

  storage_mb = var.storage_gb * 1024

  subnet_id           = var.vnet.data.infrastructure.delegated_subnets["Microsoft.DBforPostgreSQL/flexibleServers"].subnet_id
  private_dns_zone_id = var.vnet.data.infrastructure.delegated_subnets["Microsoft.DBforPostgreSQL/flexibleServers"].private_dns_zone_id
}

resource "random_password" "master_password" {
  length  = 10
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.vnet.specs.azure.region
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.md_metadata.name_prefix
  resource_group_name    = azurerm_resource_group.main.name
  location               = var.vnet.specs.azure.region
  version                = var.postgres_version
  delegated_subnet_id    = local.subnet_id
  private_dns_zone_id    = local.private_dns_zone_id
  administrator_login    = var.username
  administrator_password = random_password.master_password.result

  dynamic "high_availability" {
    for_each = var.high_availability ? toset(["enabled"]) : toset([])
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

  storage_mb = local.storage_mb
  sku_name   = local.sku
}
