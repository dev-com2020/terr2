variable "storage_account_name" {
  description = "Name of the Azure Storage Account"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default = "rg-28-set"
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
  default     = "West Europe"
}

variable "account_tier" {
  description = "Tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Replication type for the storage account (LRS, GRS, etc.)"
  type        = string
  default     = "LRS"
}