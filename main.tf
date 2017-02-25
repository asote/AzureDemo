# Set terraform provider. Using environment variables for:
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# ARM_CLIENT_SECRET
# ARM_TENANT_ID

provider "azurerm" {}

# Create Azure resource group.
resource "azurerm_resource_group" "rg" {
  name     = "${var.azure-resourcegroup}"
  location = "${var.azure-region}"
}

# Create Azure storage account and container for VHDs.
resource "azurerm_storage_account" "storage" {
  name                = "${var.azure-storageacc}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location     = "${azurerm_resource_group.rg.location}"
  account_type = "${var.azure-storageacctype}"

  tags {
    environment = "test"
  }
}

resource "azurerm_storage_container" "blob1" {
  name                  = "${var.azure-blobcontainer}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "private"
}
