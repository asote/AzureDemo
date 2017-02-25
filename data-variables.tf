variable "admin_username" {
  description = "administrator's user name"
  default     = "administrator"
}

variable "admin_password" {
  description = "administrator's password"
}

variable "azure-region" {
  description = "Azure Region"
  default     = "centralus"
}

variable "azure-resourcegroup" {
  description = "Azure resource group name"
  default     = "${var.azure-region}-rg"
}

variable "azure-storageacc" {
  description = "Azure storage account name."
  default     = "${var.azure-resourcegroup}-sta"
}

variable "azure-storageacctype" {
  description = "Azure storage account type."
  default     = "Standard_GRS"
}

variable "azure-blobcontainer" {
  description = "Azure storage blob container name."
  default     = "vhds"
}
