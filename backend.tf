terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-dev"
    storage_account_name = "sttfamitkurmapu28"
    container_name       = "tfstate"
    key                  = "landingzone-dev.tfstate"
    use_azuread_auth     = true
  }
}