variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "centralindia"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-landingzone-dev"
}

variable "address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet address prefixes"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}