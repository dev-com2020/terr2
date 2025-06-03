# Konfiguracja dostawcy Azure
provider "azurerm" {
  features {}
}

# Grupa zasobów dla konta storage
resource "azurerm_resource_group" "state_rg" {
  name     = "terraform-state-rg"
  location = "West Europe"
}

# Konto storage dla backendu Terraform
resource "azurerm_storage_account" "state_storage" {
  name                     = "tfstate${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.state_rg.name
  location                 = azurerm_resource_group.state_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # włączanie wersjonowania dla ochrony stanu
    blob_properties {
        versioning_enabled = true
    }
}

# Kontener na plik stanu
resource "azurerm_storage_container" "state_container" {
  name= "tfstate"
  storage_account_name = azurerm_storage_account.state_storage.name
  container_access_type = "private"
}

# Losowy sufiks dla unikalnej nazwy konta storage
resource "random_string" "storage_suffix" {
  length = 8
  special = false
  upper = false
}

# Konfiguracja backend
terraform {
  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "tfstate${random_string.storage_suffix.result}"
    container_name = "tfstate"
    key = "prod.terraform.tfstate"
  }
}
# testowy zasób
resource "azurerm_resource_group" "prod_rg" {
    name = "prod-ennvironment-rg"
    location = "West Europe"
}

