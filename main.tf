#REDIS CACHE
resource "azurerm_redis_cache" "redi" {
  for_each                      = local.map_redi_params
  name                          = each.value.redi_name
  resource_group_name           = each.value.rsgr_name
  location                      = each.key
  zones                         = length(local.availability_zones) > 0 ? local.availability_zones : null
  capacity                      = var.redi_capacity
  family                        = var.redi_family
  sku_name                      = var.redi_sku_name
  shard_count                   = var.redi_shard_count
  non_ssl_port_enabled          = local.redi_enable_non_ssl_port
  minimum_tls_version           = local.redi_minimum_tls_version
  subnet_id = local.is_vnet_injection ? each.value.redi_existing_subnet_id : null
  public_network_access_enabled = local.public_network_access_enabled
  redis_version                 = local.redi_version
  tags                          = merge(var.tags, local.tags)
  dynamic "patch_schedule" {
    for_each = var.schedule_updates
    content {
      day_of_week    = lower(patch_schedule.value["day"])
      start_hour_utc = patch_schedule.value["hour"]
    }
  }

  lifecycle {

    precondition { # VNET Injection y Private endpoint no pueden habilitarse a la vez.
      condition     = !(var.enable_private_endpoint && var.enable_vnet_injection)
      error_message = "VNET injection and private endpoint cannot both be enabled at the same time."
    }

    precondition { # Habilitar VNET Injection solo es posible en SKU Premium
      condition     = !(var.enable_vnet_injection == true && var.redi_sku_name != "Premium")
      error_message = "VNET injection can only be enabled if Redis SKU is 'Premium'."
    }

    precondition { # Definir una IP estática solo es posible si se ha habilitado el Private Endpoint
      condition     = var.enable_private_endpoint || var.redi_pve_ip_static == null
      error_message = "IP Static can only be defined when private endpoint is enabled."
    }
  }

  depends_on = [
    azurerm_redis_cache.redi
  ]
}

#[LBS] Firewall REDIS
resource "azurerm_redis_firewall_rule" "redi_fw" {
  for_each = local.redi_assosiation_ip_name

  name                = each.value.name_rule
  redis_cache_name    = azurerm_redis_cache.redi[each.value.location].name
  resource_group_name = azurerm_redis_cache.redi[each.value.location].resource_group_name
  start_ip            = each.value.start_ip
  end_ip              = each.value.end_ip

  depends_on = [
    azurerm_redis_cache.redi
  ]
}

resource "azurerm_redis_firewall_rule" "redi_aks_egress" {
  for_each = length(values(var.redi_ip_aks_egress)) != 0 ? var.redi_ip_aks_egress : {}

  name                = format("%s%d", "BCP_RULE_0", length(local.redi_start_ip_restriction) + 1)
  redis_cache_name    = azurerm_redis_cache.redi[each.key].name
  resource_group_name = azurerm_redis_cache.redi[each.key].resource_group_name
  start_ip            = each.value
  end_ip              = each.value

  depends_on = [
    azurerm_redis_cache.redi
  ]
}

#[LBS] Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "redi" {
  for_each = azurerm_redis_cache.redi

  name                       = format("%s%s", each.value.name, "-logsseg")
  target_resource_id         = each.value.id
  log_analytics_workspace_id = var.redi_lgan_segu_id[each.key]


  enabled_log {
    category = "ConnectedClientList"
  }

  lifecycle {
    ignore_changes = [metric]
  }

}


  
