output "app_service_url" {
  description = "App Service URL"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_name" {
  description = "App Service Name"
  value       = azurerm_linux_web_app.main.name
}

output "eventhub_namespace" {
  description = "Event Hub Namespace"
  value       = var.enable_eventhub ? azurerm_eventhub_namespace.main[0].name : null
}

output "eventhub_name" {
  description = "Event Hub Name"
  value       = var.enable_eventhub ? azurerm_eventhub.main[0].name : null
}
