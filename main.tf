# Set terraform provider. Using environment variables for:
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# ARM_CLIENT_SECRET
# ARM_TENANT_ID

provider "azurerm" {}

# Create Azure resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.azure-resourcegroup}"
  location = "${var.azure-region}"
}
