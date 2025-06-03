output "storage_account_id" {
    description = "value"
    value = azurerm_storage_account.storage.id  
}

output "storage_account_endpoint" {
    description = "value"
    value = azurerm_storage_account.storage.primary_blob_endpoint
}