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
