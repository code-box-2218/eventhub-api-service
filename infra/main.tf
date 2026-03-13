terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  skip_provider_registration = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    app = var.app_name
    env = var.environment
  }
}

# App Service Plan (Linux)
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.app_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

# App Service for Spring Boot
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.app_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    minimum_tls_version = "1.2"
    
    application_stack {
      java_version            = "17"
      java_server             = "TOMCAT"
      java_server_version     = "10.0"
    }
  }

  app_settings = {
    "WEBSITES_PORT"              = "8080"
    "SPRING_PROFILES_ACTIVE"     = var.environment
  }
}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "main" {
  count               = var.enable_eventhub ? 1 : 0
  name                = "evhns-${var.app_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  capacity            = 1
}

# Event Hub
resource "azurerm_eventhub" "main" {
  count               = var.enable_eventhub ? 1 : 0
  name                = "evh-${var.app_name}"
  namespace_name      = azurerm_eventhub_namespace.main[0].name
  resource_group_name = azurerm_resource_group.main.name
  partition_count     = 2
  message_retention   = 1
}

# RBAC: App Service can send/receive events
resource "azurerm_role_assignment" "eventhub_sender" {
  count              = var.enable_eventhub ? 1 : 0
  scope              = azurerm_eventhub_namespace.main[0].id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id       = azurerm_linux_web_app.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "eventhub_receiver" {
  count              = var.enable_eventhub ? 1 : 0
  scope              = azurerm_eventhub_namespace.main[0].id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id       = azurerm_linux_web_app.main.identity[0].principal_id
}
