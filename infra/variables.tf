variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Application name (lowercase, no spaces)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_service_sku" {
  description = "App Service Plan SKU (B1, B2, S1, S2, P1V2, etc)"
  type        = string
  default     = "B1"
}

variable "enable_eventhub" {
  description = "Deploy Event Hub for messaging"
  type        = bool
  default     = true
}
