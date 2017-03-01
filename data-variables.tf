variable "location" {
  description = "Azure region, resource group name, environment."

  default = {
    region = "centralus"
    rsgrp  = "demo-rg"
    env    = "demo"
  }
}

variable "storage" {
  description = "Storage account name, type and blob container."

  default = {
    storaccname  = "demosta1"
    storacctype  = "Standard_GRS"
    contname     = "vhds"
    contsecurity = "private"
  }
}

variable "virtualnetwork" {
  description = "Virtual Network name and cidr block."

  default = {
    vnetname = "development"
    cidrblk  = "10.0.0.0/16"
    dns      = "168.63.129.16" # default Azure DNS for virtual public IP address that is used to facilitate a communication channel to internal platform resources for the bring-your-own IP Virtual Network scenario. 
  }
}

variable "subnet" {
  description = "Subnet cidr blocks."

  default = {
    web  = "10.0.1.0/24"
    app  = "10.0.2.0/24"
    data = "10.0.3.0/24"
    adds = "10.0.4.0/24"
    mgt  = "10.0.0.128/25"
  }
}

variable "subnetname" {
  description = "Subnet names."

  default = {
    web  = "web-tier"
    app  = "app-tier"
    data = "data-tier"
    adds = "adds-tier"
    mgt  = "mgt-tier"
  }
}

variable "nsg" {
  description = "Network Security Group names."

  default = {
    web  = "web-tier-nsg"
    app  = "app-tier-nsg"
    data = "data-tier-nsg"
    adds = "adds-tier-nsg"
    mgt  = "mgt-tier-nsg"
  }
}

variable "extlb" {
  description = "Internet facing load balancer confifguration."

  default = {
    vipname  = "LBPublicIP"
    lbname   = "Public-LB"
    frontend = "public-LoadBalancer"
    backend  = "BackEndAddressPool"
  }
}

variable "intlb" {
  description = "Intenal load balancer confifguration."

  default = {
    lbname   = "App-LB"
    frontend = "app-LoadBalancer"
    backend  = "BackEndAddressPool"
  }
}

variable "bastion-ip" {
  description = "Bastion Public IP address name. Recommended to use VPN."
  default     = "BastionPublicIP"
}

variable "webserver" {
  description = "Web server configuration."

  default = {
    count        = 2
    nic          = "vmnic-web-"
    vmsize       = "Standard_A2"
    availset     = "WebAvailSet"
    name         = "web"
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2012-R2-Datacenter"
    version      = "latest"
    datadisksize = "50"
  }
}

variable "appserver" {
  description = "App server configuration."

  default = {
    count        = 2
    nic          = "vmnic-app-"
    vmsize       = "Standard_A2"
    availset     = "AppAvailSet"
    name         = "app"
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2012-R2-Datacenter"
    version      = "latest"
    datadisksize = "50"
  }
}

variable "dataserver" {
  description = "Data server configuration."

  default = {
    count        = 2
    nic          = "vmnic-data-"
    vmsize       = "Standard_A2"
    availset     = "DataAvailSet"
    name         = "data"
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2012-R2-Datacenter"
    version      = "latest"
    datadisksize = "50"
  }
}

variable "addsserver" {
  description = "ADDS server configuration."

  default = {
    count        = 2
    nic          = "vmnic-adds-"
    vmsize       = "Standard_A2"
    availset     = "ADDSAvailSet"
    name         = "adds"
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2012-R2-Datacenter"
    version      = "latest"
    datadisksize = "50"
  }
}

variable "mgtserver" {
  description = "Mgt server configuration."

  default = {
    count        = 1
    nic          = "vmnic-mgt-"
    vmsize       = "Standard_A2"
    availset     = "MgtAvailSet"
    name         = "mgt"
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2012-R2-Datacenter"
    version      = "latest"
    datadisksize = "50"
  }
}

variable "admin" {
  description = "Administrator credentials."

  default = {
    user = "rabbit"
    pwd  = "U7$dHa3*fK3"
  }
}
