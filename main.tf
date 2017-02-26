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
  name                = "${var.app-nsg}"
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
  name                = "${var.data-nsg}"
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

resource "azurerm_subnet" "adds" {
  name                      = "${var.adds-subnet}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.adds-cidr}"
  network_security_group_id = "${azurerm_network_security_group.adds-nsg.id}"
}

# Active Directory NSG

resource "azurerm_network_security_group" "adds-nsg" {
  name                = "${var.adds-nsg}"
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
    source_address_prefix      = "${var.data-cidr}"
    destination_address_prefix = "${var.adds-cidr}"
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
    destination_address_prefix = "${var.adds-cidr}"
  }

  security_rule {
    name                       = "allow-RDP"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.adds-cidr}"
    destination_address_prefix = "${var.mgt-cidr}"
  }
}

# Management subnet

resource "azurerm_subnet" "mgt" {
  name                      = "${var.mgt-subnet}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.mgt-cidr}"
  network_security_group_id = "${azurerm_network_security_group.mgt-nsg.id}"
}

# Management subnet NSG

resource "azurerm_network_security_group" "mgt-nsg" {
  name                = "${var.mgt-nsg}"
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
    destination_address_prefix = "${var.mgt-cidr}"
  }
}

# Create Virtual Machines

# VMs for public subnet

# Public subnet nics
resource "azurerm_network_interface" "public" {
  count               = "${var.web-count}"
  name                = "${var.webvm-nicname}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.public-nsg.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index +1}"
    subnet_id                               = "${azurerm_subnet.public.id}"
    private_ip_address_allocation           = "Static"
    private_ip_address                      = "${var.web-staticip}${count.index + 5}"
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
  name                         = "${var.web-availset}"
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
  count = "${var.web-count}"
  name  = "${var.webserver-name}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.public.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.web.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.web-vmsize}"

  storage_image_reference {
    publisher = "${var.webimage-publisher}"
    offer     = "${var.webimage-offer}"
    sku       = "${var.webimage-sku}"
    version   = "${var.webimage-version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.webserver-name}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.webserver-name}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.webserver-name}${count.index + 1}"
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
  count               = "${var.app-count}"
  name                = "${var.appvm-nicname}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.app-nsg.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index +1}"
    subnet_id                               = "${azurerm_subnet.app.id}"
    private_ip_address_allocation           = "Static"
    private_ip_address                      = "${var.app-staticip}${count.index + 5}"
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
  name                         = "${var.app-availset}"
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
  count = "${var.app-count}"
  name  = "${var.appserver-name}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.app.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.app.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.app-vmsize}"

  storage_image_reference {
    publisher = "${var.appimage-publisher}"
    offer     = "${var.appimage-offer}"
    sku       = "${var.appimage-sku}"
    version   = "${var.appimage-version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.appserver-name}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.appserver-name}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.appserver-name}${count.index + 1}"
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
  count               = "${var.data-count}"
  name                = "${var.datavm-nicname}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.data-nsg.id}"

  ip_configuration {
    name                          = "ipconfig${count.index +1}"
    subnet_id                     = "${azurerm_subnet.data.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.data-staticip}${count.index + 5}"
  }
}

# Data tier availability set
resource "azurerm_availability_set" "data" {
  name                         = "${var.data-availset}"
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
  count = "${var.data-count}"
  name  = "${var.dataserver-name}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.data.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.data.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.data-vmsize}"

  storage_image_reference {
    publisher = "${var.dataimage-publisher}"
    offer     = "${var.dataimage-offer}"
    sku       = "${var.dataimage-sku}"
    version   = "${var.dataimage-version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.dataserver-name}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.dataserver-name}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.dataserver-name}${count.index + 1}"
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
  count               = "${var.adds-count}"
  name                = "${var.addsvm-nicname}${count.index + 1}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  network_security_group_id = "${azurerm_network_security_group.adds-nsg.id}"

  ip_configuration {
    name                          = "ipconfig${count.index +1}"
    subnet_id                     = "${azurerm_subnet.adds.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.adds-staticip}${count.index + 5}"
  }
}

# ADDS Availability Set
resource "azurerm_availability_set" "adds" {
  name                         = "${var.adds-availset}"
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
  count = "${var.adds-count}"
  name  = "${var.addsserver-name}${count.index + 1}"

  location = "${azurerm_resource_group.rg.location}"

  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.adds.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.adds.id}"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"
  vm_size                          = "${var.adds-vmsize}"

  storage_image_reference {
    publisher = "${var.addsimage-publisher}"
    offer     = "${var.addsimage-offer}"
    sku       = "${var.addsimage-sku}"
    version   = "${var.addsimage-version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.addsserver-name}${count.index + 1}-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk${count.index}"
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.blob.name}/${var.addsserver-name}${count.index + 1}-datadisk${count.index}.vhd"
    disk_size_gb  = "${var.datadisk-size}"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.addsserver-name}${count.index + 1}"
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
  count               = "${var.mgt-count}"
  name                = "${var.mgtvm-nicname}${count.index + 1}"
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
