output "resource_group_name" {
  description = "Name of the lab resource group"
  value       = azurerm_resource_group.lab.name
}

output "virtual_machine_name" {
  description = "Name of the Windows Server VM"
  value       = azurerm_windows_virtual_machine.lab.name
}

output "virtual_machine_private_ip" {
  description = "Private IP address of the Windows VM"
  value       = azurerm_network_interface.lab.private_ip_address
}

output "virtual_machine_public_ip" {
  description = "Public IP address assigned to the VM"
  value       = azurerm_public_ip.lab.ip_address
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.lab.name
}

output "data_collection_rule_name" {
  description = "Name of the Windows monitoring Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.lab.name
}