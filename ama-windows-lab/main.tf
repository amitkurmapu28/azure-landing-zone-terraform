
# 1. Resource group
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# 2. Virtual network
resource "azurerm_virtual_network" "lab" {
  name                = "vnet-ama-windows-lab"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

# 3. Subnet
resource "azurerm_subnet" "lab" {
  name                 = "snet-ama-windows-lab"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.1.0/24"]
}

# 4. Network security group
# No inbound RDP rule is configured.
resource "azurerm_network_security_group" "lab" {
  name                = "nsg-ama-windows-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

# 5. Public IP
resource "azurerm_public_ip" "lab" {
  name                = "pip-ama-windows-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# 6. Network interface
resource "azurerm_network_interface" "lab" {
  name                = "nic-ama-windows-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}

# 7. Associate NSG with the network interface
resource "azurerm_network_interface_security_group_association" "lab" {
  network_interface_id      = azurerm_network_interface.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

# 8. Windows Server virtual machine
resource "azurerm_windows_virtual_machine" "lab" {
  name                = var.vm_name
  computer_name       = "ama-win-lab01"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_D2s_v5"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.lab.id
  ]

  os_disk {
    name                 = "osdisk-ama-windows-lab"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = var.tags
}

# 9. Log Analytics workspace
resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-ama-windows-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# 10. Azure Monitor Agent for Windows
resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.lab.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

# 11. Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "lab" {
  name                = "dcr-ama-windows-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  kind                = "Windows"
  description         = "Collect Windows event logs and performance counters"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = "law-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.lab.id
    }
  }

  data_flow {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = ["law-destination"]
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["law-destination"]
  }

  data_sources {
    windows_event_log {
      name    = "windows-event-source"
      streams = ["Microsoft-WindowsEvent"]

      x_path_queries = [
        "Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]",
        "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
      ]
    }

    performance_counter {
      name                          = "windows-performance-source"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
    }
  }
}
