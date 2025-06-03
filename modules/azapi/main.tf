terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "azapi" {
  # authentication via az CLI or environment variables
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}


resource "azapi_resource" "rg" {
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
  name      = "rg-demo-azapi"
  location  = "westeurope"
  body = jsonencode({})
}

resource "azapi_resource" "storage" {
  type      = "Microsoft.Storage/storageAccounts@2021-09-01"
  name      = "accountsftpdemo${random_string.random.result}"
  location  = azapi_resource.rg.location
  parent_id = azapi_resource.rg.id

  body = jsonencode({
    sku = {
      name = "Standard_LRS"
    }
    kind = "StorageV2"
    properties = {
      isHnsEnabled    = true
      minimumTlsVersion = "TLS1_2"
    }
  })
}

resource "azapi_update_resource" "enable_sftp" {
  type        = "Microsoft.Storage/storageAccounts@2021-09-01"
  resource_id = azapi_resource.storage.id

  body = jsonencode({
    properties = {
      isSftpEnabled = true
    }
  })
}
