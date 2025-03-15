variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID"
  type        = string
}

variable "client_id" {
  description = "The Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "The Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}