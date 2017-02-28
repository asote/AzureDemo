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
  name                = "${var.storage["storaccname"]}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location     = "${azurerm_resource_group.rg.location}"
  account_type = "${var.storage["storacctype"]}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_storage_container" "blob" {
  name                  = "${var.storage["contname"]}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "${var.storage["contsecurity"]}"
}

# Create Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtualnetwork["vnetname"]}"
  address_space       = ["${var.virtualnetwork["cidrblk"]}"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  dns_servers         = ["${var.virtualnetwork["dns"]}"]
}

# Create virtual network subnets

# Public subnet
resource "azurerm_subnet" "public" {
  name                      = "${var.subnetname["web"]}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.subnet["web"]}"
  network_security_group_id = "${azurerm_network_security_group.public-nsg.id}"
}

# Public subnet NSG
resource "azurerm_network_security_group" "public-nsg" {
  name                = "${var.nsgname["web"]}"
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
    destination_address_prefix = "${var.subnet["web"]}"
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
    destination_address_prefix = "${var.subnet["web"]}"
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
    destination_address_prefix = "${var.subnet["web"]}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.subnet["web"]}"
    destination_address_prefix = "${var.subnet["mgt"]}"
  }
}

# App subnet
resource "azurerm_subnet" "app" {
  name                      = "${var.subnetname["app"]}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.subnet["app"]}"
  network_security_group_id = "${azurerm_network_security_group.app-nsg.id}"
}

# App subnet NSG
resource "azurerm_network_security_group" "app-nsg" {
  name                = "${var.nsgname["app"]}"
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
    source_address_prefix      = "${var.subnet["web"]}"
    destination_address_prefix = "${var.subnet["app"]}"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "${var.subnet["web"]}"
    destination_address_prefix = "${var.subnet["app"]}"
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
    destination_address_prefix = "${var.subnet["app"]}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.subnet["app"]}"
    destination_address_prefix = "${var.subnet["mgt"]}"
  }
}

# Data subnet

resource "azurerm_subnet" "data" {
  name                      = "${var.subnetname["data"]}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.subnet["data"]}"
  network_security_group_id = "${azurerm_network_security_group.data-nsg.id}"
}

# Data subnet NSG
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg
#
# Allow SQL and RDP.  Deny HTTP from tier1,tier2 and Internet 

resource "azurerm_network_security_group" "data-nsg" {
  name                = "${var.nsgname["data"]}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-sql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "${var.subnet["app"]}"
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
    source_address_prefix      = "${var.subnet["app"]}"
    destination_address_prefix = "${var.subnet["mgt"]}"
  }

  security_rule {
    name                       = "Deny-tier2-inTraffic"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.subnet["app"]}"
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
    destination_address_prefix = "${var.subnet["app"]}"
  }

  security_rule {
    name                       = "Deny-tier1-inTraffic"
    priority                   = 220
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.subnet["web"]}"
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
    destination_address_prefix = "${var.subnet["web"]}"
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

resource "azurerm_subnet" "adds" {
  name                      = "${var.subnetname["adds"]}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.subnet["adds"]}"
  network_security_group_id = "${azurerm_network_security_group.adds-nsg.id}"
}

# Active Directory NSG

resource "azurerm_network_security_group" "adds-nsg" {
  name                = "${var.nsgname["adds"]}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-tcp-ad"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "${var.subnet["data"]}"
    destination_address_prefix = "${var.subnet["adds"]}"
  }

  security_rule {
    name                       = "allow-winrm"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.subnet["adds"]}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.subnet["adds"]}"
    destination_address_prefix = "${var.subnet["mgt"]}"
  }
}

# Management subnet

resource "azurerm_subnet" "mgt" {
  name                      = "${var.subnetname["mgt"]}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.subnet["mgt"]}"
  network_security_group_id = "${azurerm_network_security_group.mgt-nsg.id}"
}

# Management subnet NSG

resource "azurerm_network_security_group" "mgt-nsg" {
  name                = "${var.nsgname["mgt"]}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "${var.subnet["mgt"]}"
  }
}

# Create Virtual Machines

# VMs for public subnet

# Public subnet nics
resource "azurerm_network_interface" "public" {
  count               = "${var.webserver["count"]}"
  name                = "${var.webserver["nic"]}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.public-nsg.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index +1}"
    subnet_id                               = "${azurerm_subnet.public.id}"
    private_ip_address_allocation           = "Static"
    private_ip_address                      = "${var.webserver["ip"]}${count.index + 5}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.public.id}"]
  }
}

# Internet facing load load balancer

# Load Balancer VIP address
resource "azurerm_public_ip" "vip" {
  name                         = "${var.vip-name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

# Front End Load Balancer
resource "azurerm_lb" "public" {
  name                = "${var.lb-name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "${var.fe-ipconfig}"
    public_ip_address_id = "${azurerm_public_ip.vip.id}"
  }
}

# Back End Address Pool
resource "azurerm_lb_backend_address_pool" "public" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public.id}"
  name                = "${var.be-ippoolname}"
}

# Load Balancer Rules
resource "azurerm_lb_rule" "http-rule-public" {
  location                       = "${azurerm_resource_group.rg.location}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.fe-ipconfig}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public.id}"
  probe_id                       = "${azurerm_lb_probe.http-public.id}"
  depends_on                     = ["azurerm_lb_probe.http-public"]
}

resource "azurerm_lb_rule" "https-rule-public" {
  location                       = "${azurerm_resource_group.rg.location}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.fe-ipconfig}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public.id}"
  probe_id                       = "${azurerm_lb_probe.https-public.id}"
  depends_on                     = ["azurerm_lb_probe.https-public"]
}

resource "azurerm_lb_probe" "http-public" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public.id}"
  name                = "HTTP"
  port                = 80
}

resource "azurerm_lb_probe" "https-public" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public.id}"
  name                = "HTTPS"
  port                = 443
}

# Web tier availability set.
resource "azurerm_availability_set" "web" {
  name                         = "${var.webserver["availset"]}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}

# Web servers
resource "azurerm_virtual_machine" "web" {
  count = "${var.webserver["count"]}"
  name  = "${var.webserver["name"]}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.public.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.web.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.webserver["vmsize"]}"
  depends_on                       = ["azurerm_network_interface.public", "azurerm_lb.public"]

  storage_image_reference {
    publisher = "${var.webserver["publisher"]}"
    offer     = "${var.webserver["offer"]}"
    sku       = "${var.webserver["sku"]}"
    version   = "${var.webserver["version"]}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.webserver["name"]}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.webserver["name"]}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.webserver["name"]}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "false"
    provision_vm_agent        = "true"
  }

  tags {
    environment = "${var.environment}"
  }
}

# VMs for App subnet
# App subnet nics
resource "azurerm_network_interface" "app" {
  count               = "${var.appserver["count"]}"
  name                = "${var.appserver["name"]}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.app-nsg.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index +1}"
    subnet_id                               = "${azurerm_subnet.app.id}"
    private_ip_address_allocation           = "Static"
    private_ip_address                      = "${var.appserver["ip"]}${count.index + 5}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.app.id}"]
  }
}

# Internal load balancer

# Front End Load Balancer
resource "azurerm_lb" "app" {
  name                = "${var.intlb-name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                          = "${var.intfe-ipconfig}"
    subnet_id                     = "${azurerm_subnet.app.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

# Back End Address Pool
resource "azurerm_lb_backend_address_pool" "app" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.app.id}"
  name                = "${var.intbe-ippoolname}"
}

# Load Balancer Rules
resource "azurerm_lb_rule" "http-rule-app" {
  location                       = "${azurerm_resource_group.rg.location}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.app.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.intfe-ipconfig}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.app.id}"
  probe_id                       = "${azurerm_lb_probe.http-app.id}"
  depends_on                     = ["azurerm_lb_probe.http-app"]
}

resource "azurerm_lb_rule" "https-rule-app" {
  location                       = "${azurerm_resource_group.rg.location}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.app.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.intfe-ipconfig}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.app.id}"
  probe_id                       = "${azurerm_lb_probe.https-app.id}"
  depends_on                     = ["azurerm_lb_probe.https-app"]
}

resource "azurerm_lb_probe" "http-app" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.app.id}"
  name                = "HTTP"
  port                = 80
}

resource "azurerm_lb_probe" "https-app" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.app.id}"
  name                = "HTTPS"
  port                = 443
}

# App tier Availability Set
resource "azurerm_availability_set" "app" {
  name                         = "${var.appserver["availset"]}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}

# App servers
resource "azurerm_virtual_machine" "app" {
  count = "${var.appserver["count"]}"
  name  = "${var.appserver["name"]}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.app.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.app.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.appserver["vmsize"]}"
  depends_on                       = ["azurerm_network_interface.app", "azurerm_lb.app"]

  storage_image_reference {
    publisher = "${var.appserver["publisher"]}"
    offer     = "${var.appserver["offer"]}"
    sku       = "${var.appserver["sku"]}"
    version   = "${var.appserver["version"]}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.appserver["name"]}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.appserver["name"]}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.appserver["name"]}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "false"
    provision_vm_agent        = "true"
  }

  tags {
    environment = "${var.environment}"
  }
}

# VMs for Data subnet
# Data subnet nics.

resource "azurerm_network_interface" "data" {
  count               = "${var.dataserver["count"]}"
  name                = "${var.dataserver["nic"]}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.data-nsg.id}"

  ip_configuration {
    name                          = "ipconfig${count.index +1}"
    subnet_id                     = "${azurerm_subnet.data.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.dataserver["ip"]}${count.index + 5}"
  }
}

# Data tier availability set
resource "azurerm_availability_set" "data" {
  name                         = "${var.dataserver["availset"]}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}

# Database servers
resource "azurerm_virtual_machine" "data" {
  count = "${var.dataserver["count"]}"
  name  = "${var.dataserver["name"]}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.data.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.data.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.dataserver["vmsize"]}"
  depends_on                       = ["azurerm_network_interface.data"]

  storage_image_reference {
    publisher = "${var.dataserver["publisher"]}"
    offer     = "${var.dataserver["offer"]}"
    sku       = "${var.dataserver["sku"]}"
    version   = "${var.dataserver["version"]}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.dataserver["name"]}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.dataserver["name"]}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.dataserver["name"]}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "false"
    provision_vm_agent        = "true"
  }

  tags {
    environment = "${var.environment}"
  }
}

# VMs for ADDS subnet
# ADDS subnet nics.

resource "azurerm_network_interface" "adds" {
  count               = "${var.addsserver["count"]}"
  name                = "${var.addsserver["nic"]}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.adds-nsg.id}"

  ip_configuration {
    name                          = "ipconfig${count.index +1}"
    subnet_id                     = "${azurerm_subnet.adds.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.addsserver["ip"]}${count.index + 5}"
  }
}

# ADDS Availability Set
resource "azurerm_availability_set" "adds" {
  name                         = "${var.addsserver["availset"]}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}

# Domain Controllers
resource "azurerm_virtual_machine" "adds" {
  count = "${var.addsserver["count"]}"
  name  = "${var.addsserver["name"]}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.adds.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.adds.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.addsserver["vmsize"]}"
  depends_on                       = ["azurerm_network_interface.adds"]

  storage_image_reference {
    publisher = "${var.addsserver["publisher"]}"
    offer     = "${var.addsserver["offer"]}"
    sku       = "${var.addsserver["sku"]}"
    version   = "${var.addsserver["version"]}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.addsserver["name"]}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.addsserver["name"]}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.addsserver["name"]}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "false"
    provision_vm_agent        = "true"
  }

  tags {
    environment = "${var.environment}"
  }
}

# VMs for Management subnet
# Management subnet nics.
resource "azurerm_network_interface" "mgt" {
  count               = "${var.mgtserver["count"]}"
  name                = "${var.mgtserver["nic"]}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.mgt-nsg.id}"

  ip_configuration {
    name                          = "ipconfig${count.index +1}"
    subnet_id                     = "${azurerm_subnet.mgt.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.PublicIP.id}"
  }
}

resource "azurerm_public_ip" "PublicIP" {
  name                         = "${var.bastion-ip}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

# Management Availability Set
# ADDS Availability Set
resource "azurerm_availability_set" "mgt" {
  name                         = "${var.mgtserver["availset"]}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment}"
  }
}

# Bastion hosts
resource "azurerm_virtual_machine" "mgt" {
  count = "${var.mgtserver["count"]}"
  name  = "${var.mgtserver["name"]}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.mgt.*.id, count.index)}"]
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.mgtserver["vmsize"]}"
  depends_on                       = ["azurerm_network_interface.mgt"]

  storage_image_reference {
    publisher = "${var.mgtserver["publisher"]}"
    offer     = "${var.mgtserver["offer"]}"
    sku       = "${var.mgtserver["sku"]}"
    version   = "${var.mgtserver["version"]}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.mgtserver["name"]}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.mgtserver["name"]}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.mgtserver["name"]}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "false"
    provision_vm_agent        = "true"
  }

  tags {
    environment = "${var.environment}"
  }
}
