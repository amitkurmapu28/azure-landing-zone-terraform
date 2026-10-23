variable "subscription_id" {
  description = "Azure subscription ID for this lab"
  type        = string
}

variable "location" {
  description = "Azure region for lab resources"
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Resource group for the Azure Monitor Agent lab"
  type        = string
  default     = "rg-ama-windows-lab"
}

variable "vm_name" {
  description = "Windows Server VM name"
  type        = string
  default     = "vm-ama-windows-01"
}

variable "admin_username" {
  description = "Local administrator username for the Windows VM"
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Windows VM administrator password; supply as a secret"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to lab resources"
  type        = map(string)
  default = {
    project     = "ama-windows-lab"
    environment = "learning"
    managed_by  = "terraform"
  }
}