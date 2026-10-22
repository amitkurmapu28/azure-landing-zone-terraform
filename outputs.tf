output "resource_group_name" {
  value = azurerm_resource_group.landing_zone.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.landing_zone.name
}

output "subnet_id" {
  value = azurerm_subnet.landing_zone.id
}

output "storage_account_name" {
  value = azurerm_storage_account.landing_zone.name
}

output "key_vault_name" {
  value = azurerm_key_vault.landing_zone.name
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.landing_zone.name
}