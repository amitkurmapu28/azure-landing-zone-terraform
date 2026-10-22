# Generate a suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 1. Resource Group
resource "azurerm_resource_group" "landing_zone" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Azure-Landing-Zone"
  }
}

# 2. Virtual Network
resource "azurerm_virtual_network" "landing_zone" {
  name                = "vnet-landingzone-${var.environment}"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  address_space       = var.address_space

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 3. Subnet
resource "azurerm_subnet" "landing_zone" {
  name                 = "snet-workload-${var.environment}"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = var.subnet_prefixes
}

# 4. Storage Account
resource "azurerm_storage_account" "landing_zone" {
  name = "stlz${random_string.suffix.result}"

  resource_group_name = azurerm_resource_group.landing_zone.name
  location            = azurerm_resource_group.landing_zone.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 5. Key Vault
resource "azurerm_key_vault" "landing_zone" {
  name = "kv-lz-${random_string.suffix.result}"

  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  rbac_authorization_enabled = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Current Azure identity/tenant information
data "azurerm_client_config" "current" {}

# 6. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "landing_zone" {
  name = "law-lz-${random_string.suffix.result}"

  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 7. Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "diag-keyvault"
  target_resource_id         = azurerm_key_vault.landing_zone.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.landing_zone.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# 8. Storage Account Blob Service Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name = "diag-storage-blob"

  target_resource_id = "${azurerm_storage_account.landing_zone.id}/blobServices/default"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.landing_zone.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "Transaction"
  }
}