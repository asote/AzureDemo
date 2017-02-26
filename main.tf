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
    environment = "${var.environment}"
  }
}

resource "azurerm_storage_container" "blob" {
  name                  = "${var.azure-blobcontainer}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "${var.azure-containertype}"
}

# Create Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}"
  address_space       = ["${var.cidr-block}"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  dns_servers         = ["${var.dns-servers}"]
}

# Create virtual network subnets

# Public subnet
resource "azurerm_subnet" "public" {
  name                      = "${var.public-subnet}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.public-cidr}"
  network_security_group_id = "${azurerm_network_security_group.public-nsg.id}"
}

# Public subnet NSG
resource "azurerm_network_security_group" "public-nsg" {
  name                = "${var.public-nsg}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "${var.public-cidr}"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "*"
    destination_address_prefix = "${var.public-cidr}"
  }

  security_rule {
    name                       = "allow-winrm"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.public-cidr}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.public-cidr}"
    destination_address_prefix = "${var.mgt-cidr}"
  }
}

# App subnet
resource "azurerm_subnet" "app" {
  name                      = "${var.app-subnet}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.app-cidr}"
  network_security_group_id = "${azurerm_network_security_group.app-nsg.id}"
}

# App subnet NSG
resource "azurerm_network_security_group" "app-nsg" {
  name                = "${var.app-subnet}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "${var.public-cidr}"
    destination_address_prefix = "${var.app-cidr}"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "${var.public-cidr}"
    destination_address_prefix = "${var.app-cidr}"
  }

  security_rule {
    name                       = "allow-winrm"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.app-cidr}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.app-cidr}"
    destination_address_prefix = "${var.mgt-cidr}"
  }
}

# Data subnet

resource "azurerm_subnet" "data" {
  name                      = "${var.data-subnet}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.data-cidr}"
  network_security_group_id = "${azurerm_network_security_group.data-nsg.id}"
}

# Data subnet NSG
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg
#
# Allow SQL and RDP.  Deny HTTP from tier1,tier2 and Internet 

resource "azurerm_network_security_group" "data-nsg" {
  name                = "sql_fw"
  location            = "${azurerm_resource_group.ResourceGrps.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGrps.name}"

  security_rule {
    name                       = "allow-sql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "${var.app-cidr}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.app-cidr}"
    destination_address_prefix = "${var.mgt-cidr}"
  }

  security_rule {
    name                       = "Deny-tier2-inTraffic"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.app-cidr}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-tier2-outTraffic"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.app-cidr}"
  }

  security_rule {
    name                       = "Deny-tier1-inTraffic"
    priority                   = 220
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.public-cidr}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-tier1-outTraffic"
    priority                   = 230
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.public-cidr}"
  }

  security_rule {
    name                       = "Deny-Internet-inTraffic"
    priority                   = 240
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-Internet-outTraffic"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "0.0.0.0/0"
  }
}

# Active Directory subnet
resource "azurerm_subnet" "subnet4" {
  name                      = "ADDS_net"
  resource_group_name       = "${azurerm_resource_group.ResourceGrps.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet1.name}"
  address_prefix            = "10.0.4.0/27"
  network_security_group_id = "${azurerm_network_security_group.tier4_fw.id}"
}

resource "azurerm_subnet" "subnet5" {
  name                      = "management_net"
  resource_group_name       = "${azurerm_resource_group.ResourceGrps.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet1.name}"
  address_prefix            = "10.0.0.128/25"
  network_security_group_id = "${azurerm_network_security_group.tier5_fw.id}"
}
