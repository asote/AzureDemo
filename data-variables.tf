variable "admin_username" {
  description = "administrator's user name. Cannot be administrator"
}

variable "admin_password" {
  description = "administrator's password. Use upper lower case, numbers and symbols."
}

variable "azure-region" {
  description = "Azure Region"
  default     = "centralus"
}

variable "azure-resourcegroup" {
  description = "Azure resource group name"
  default     = "demo-rg"
}

variable "azure-storageacc" {
  description = "Azure storage account name."
  default     = "demosta1"
}

variable "azure-storageacctype" {
  description = "Azure storage account type."
  default     = "Standard_GRS"
}

variable "azure-blobcontainer" {
  description = "Azure storage blob container name."
  default     = "vhds"
}

variable "azure-containertype" {
  description = "Azure storage blob container type."
  default     = "private"
}

variable "environment" {
  description = "Tag name for environment"
  default     = "dev"
}

variable "vnet" {
  description = "Virtual Network Name"
  default     = "development"
}

variable "cidr-block" {
  description = "Virtual Network Address Space."
  default     = "10.0.0.0/16"
}

variable "dns-servers" {
  description = "DNS servers."
  default     = "168.63.129.16" # default Azure DNS for virtual public IP address that is used to facilitate a communication channel to internal platform resources for the bring-your-own IP Virtual Network scenario. 
}

variable "public-subnet" {
  description = "Public subnet name"
  default     = "web-tier"
}

variable "public-cidr" {
  description = "Public subnet cidr block"
  default     = "10.0.1.0/24"
}

variable "public-nsg" {
  description = "Network Security Group for public subnet."
  default     = "web-tier-nsg"
}

variable "mgt-subnet" {
  description = "Management subnet name."
  default     = "mgt-tier"
}

variable "mgt-cidr" {
  description = "Public subnet cidr block"
  default     = "10.0.0.128/25"
}

variable "mgt-nsg" {
  description = "Network Security Group for mgt subnet."
  default     = "mgt-tier-nsg"
}

variable "app-subnet" {
  description = "App subnet name."
  default     = "app-tier"
}

variable "app-cidr" {
  description = "App subnet cidr block"
  default     = "10.0.2.0/24"
}

variable "app-nsg" {
  description = "Network Security Group for app subnet."
  default     = "app-tier-nsg"
}

variable "data-subnet" {
  description = "Data subnet name."
  default     = "data-tier"
}

variable "data-cidr" {
  description = "Data subnet cidr block"
  default     = "10.0.3.0/24"
}

variable "data-nsg" {
  description = "Network Security Group for data subnet."
  default     = "data-tier-nsg"
}

variable "adds-subnet" {
  description = "Active Directory subnet name."
  default     = "adds-tier"
}

variable "adds-cidr" {
  description = "Active Directory subnet cidr block"
  default     = "10.0.4.0/27"
}

variable "adds-nsg" {
  description = "Network Security Group for ADDS subnet."
  default     = "adds-tier-nsg"
}

variable "web-count" {
  description = "Number of Virtual Machines"
  default     = 2
}

variable "webvm-nicname" {
  description = "Naming convention for web servers."
  default     = "vmnic-web-"
}

variable "web-staticip" {
  description = "Starting static IP address for web servers. First 3 octects."
  default     = "10.0.1."
}

variable "vip-name" {
  description = "Load balancer VIP name."
  default     = "LBPublicIP"
}

variable "lb-name" {
  description = "Front End Load Balancer name."
  default     = "Public-LB"
}

variable "fe-ipconfig" {
  description = "Front End IP configuration name."
  default     = "public-LoadBalancer"
}

variable "be-ippoolname" {
  description = "Back End Address Pool."
  default     = "BackEndAddressPool"
}

variable "web-availset" {
  description = "Availability Set name for web servers."
  default     = "WebAvailSet"
}

variable "webserver-name" {
  description = "Web server naming convention."
  default     = "web"
}

variable "web-vmsize" {
  description = "Web server vm size."
  default     = "Standard_A2"
}

variable "webimage-publisher" {
  description = "Image publisher."
  default     = "MicrosoftWindowsServer"
}

variable "webimage-offer" {
  description = "Image offer."
  default     = "WindowsServer"
}

variable "webimage-sku" {
  description = "Image sku."
  default     = "2012-R2-Datacenter"
}

variable "webimage-version" {
  description = "Image version."
  default     = "latest"
}

variable "datadisk-size" {
  description = "Data disk size."
  default     = "50"
}

variable "app-count" {
  description = "Number of Virtual Machines"
  default     = 2
}

variable "appvm-nicname" {
  description = "Naming convention for app servers."
  default     = "vmnic-app-"
}

variable "app-staticip" {
  description = "Starting static IP address for app servers. First 3 octects."
  default     = "10.0.2."
}

variable "intlb-name" {
  description = "Front End Load Balancer name."
  default     = "App-LB"
}

variable "intfe-ipconfig" {
  description = "Front End IP configuration name."
  default     = "app-LoadBalancer"
}

variable "intbe-ippoolname" {
  description = "Back End Address Pool."
  default     = "BackEndAddressPool"
}

variable "app-availset" {
  description = "Availability Set name for app servers."
  default     = "AppAvailSet"
}

variable "appserver-name" {
  description = "App server naming convention."
  default     = "app"
}

variable "app-vmsize" {
  description = "App server vm size."
  default     = "Standard_A2"
}

variable "appimage-publisher" {
  description = "Image publisher."
  default     = "MicrosoftWindowsServer"
}

variable "appimage-offer" {
  description = "Image offer."
  default     = "WindowsServer"
}

variable "appimage-sku" {
  description = "Image sku."
  default     = "2012-R2-Datacenter"
}

variable "appimage-version" {
  description = "Image version."
  default     = "latest"
}
