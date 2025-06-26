output "subscription_id" {
  description = "Id de la suscripcion"
  value       = data.azurerm_subscription.current.subscription_id
}
####OUTPUTS DEL MODULO####
output "redi_name" {
  description = " Mapa con los nombres de los redi aprovisionados"
  value       = { for region in keys(azurerm_redis_cache.redi) : region => azurerm_redis_cache.redi[region].name }
}

output "redi_id" {
  description = " Mapa con los Id de los redi aprovisionados"
  value       = { for region in keys(azurerm_redis_cache.redi) : region => azurerm_redis_cache.redi[region].id }
}

output "redi_flavor" {
  description = " Mapa con flavor de los redi aprovisionados"
  value       = { for region in keys(azurerm_redis_cache.redi) : region => format("%s-%s", azurerm_redis_cache.redi[region].sku_name, azurerm_redis_cache.redi[region].capacity) }
}

output "redi_connection_string" {
  description = " Mapa con los parámetros de conexión de los redi aprovisionados"
  value       = { for region in keys(azurerm_redis_cache.redi) : region => format("%s:%s,%s,%s,%s", azurerm_redis_cache.redi[region].hostname, azurerm_redis_cache.redi[region].ssl_port, "password=<key>", "ssl=True", "abortConnect=False") }
}

