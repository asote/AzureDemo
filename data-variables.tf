variable "admin" {
  description = "Administrator credentials."

  default = {
    user = "rabbit"
    pwd  = "abc123"
  }
}

variable "azure-region" {
  description = "Azure Region"
  default     = "centralus"
}

variable "azure-resourcegroup" {
  description = "Azure resource group name"
  default     = "demo-rg"
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

variable "environment" {
  description = "Tag name for environment"
  default     = "dev"
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

variable "nsgname" {
  description = "Network Security Group names."

  default = {
    web  = "web-tier-nsg"
    app  = "app-tier-nsg"
    data = "data-tier-nsg"
    adds = "adds-tier-nsg"
    mgt  = "mgt-tier-nsg"
  }
}

variable "webserver" {
  description = "Web server configuration."

  default = {
    count     = 2
    nic       = "vmnic-web-"
    ip        = "10.0.1."                # Starting static IP address for web servers. First 3 octects
    vmsize    = "Standard_A2"
    availset  = "WebAvailSet"
    name      = "web"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
}

variable "appserver" {
  description = "App server configuration."

  default = {
    count     = 2
    nic       = "vmnic-app-"
    ip        = "10.0.2."                # Starting static IP address for web servers. First 3 octects
    vmsize    = "Standard_A2"
    availset  = "AppAvailSet"
    name      = "app"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
}

variable "dataserver" {
  description = "Data server configuration."

  default = {
    count     = 2
    nic       = "vmnic-data-"
    ip        = "10.0.3."                # Starting static IP address for web servers. First 3 octects
    vmsize    = "Standard_A2"
    availset  = "DataAvailSet"
    name      = "data"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
}

variable "addsserver" {
  description = "ADDS server configuration."

  default = {
    count     = 2
    nic       = "vmnic-adds-"
    ip        = "10.0.4."                # Starting static IP address for web servers. First 3 octects
    vmsize    = "Standard_A2"
    availset  = "ADDSAvailSet"
    name      = "adds"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
}

variable "mgtserver" {
  description = "Mgt server configuration."

  default = {
    count     = 1
    nic       = "vmnic-mgt-"
    ip        = "10.0.0.128"
    vmsize    = "Standard_A2"
    availset  = "MGTSAvailSet"
    name      = "mgt"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
}

variable "datadisk-size" {
  description = "Data disk size."
  default     = "50"
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
