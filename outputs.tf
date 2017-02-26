output "webservers_name" {
  description = "Web Servers names."
  value       = ["${azurerm_virtual_machine.web.*.name}"]
}

output "webservers_ip" {
  description = "Web Servers IP addresses."
  value       = ["${azurerm_network_interface.public.*.private_ip_address}"]
}

output "appservers_name" {
  description = "App Servers names."
  value       = ["${azurerm_virtual_machine.app.*.name}"]
}

output "appservers_ip" {
  description = "App Servers IP addresses."
  value       = ["${azurerm_network_interface.app.*.private_ip_address}"]
}

output "dataservers_name" {
  description = "Database Servers names."
  value       = ["${azurerm_virtual_machine.data.*.name}"]
}

output "dataservers_ip" {
  description = "Database  Servers IP addresses."
  value       = ["${azurerm_network_interface.data.*.private_ip_address}"]
}

output "addsservers_name" {
  description = "Domain Controllers names."
  value       = ["${azurerm_virtual_machine.adds.*.name}"]
}

output "addsservers_ip" {
  description = "adds Servers IP addresses."
  value       = ["${azurerm_network_interface.adds.*.private_ip_address}"]
}

output "bastion_name" {
  description = "Management Servers (Bastion host) names."
  value       = ["${azurerm_virtual_machine.mgt.*.name}"]
}

output "bastion_priv-ip" {
  description = "Bastion hosts private IP addresses."
  value       = ["${azurerm_network_interface.mgt.*.private_ip_address}"]
}

output "bastion_pub-ip" {
  description = "Bastion hosts public IP addresses."
  value       = ["${azurerm_public_ip.PublicIP.*.ip_address}"]
}

output "LB_VIP_IP" {
  description = "Internet facing LB VIP."
  value       = ["${azurerm_public_ip.vip.ip_address}"]
}

output "LB_VIP_DNS" {
  description = "Internet facing LB DNS."
  value       = ["${azurerm_public_ip.vip.fqdn}"]
}
