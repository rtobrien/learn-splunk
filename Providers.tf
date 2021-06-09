# ====================================================================================
# Defining Provider Data
# ====================================================================================

provider "azurerm" {
    subscription_id                         = var.subscription_id
    features {}
}

terraform {
  backend "azurerm" {
      resource_group_name               = "tf-data"
      storage_account_name              = "rtobtfstate"
      container_name                    = "tfstate"
      key                               = "tf.state"
  }
}