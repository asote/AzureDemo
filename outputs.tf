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
  description = "data Servers names."
  value       = ["${azurerm_virtual_machine.data.*.name}"]
}

output "dataservers_ip" {
  description = "App Servers IP addresses."
  value       = ["${azurerm_network_interface.data.*.private_ip_address}"]
}

output "addsservers_name" {
  description = "adds Servers names."
  value       = ["${azurerm_virtual_machine.adds.*.name}"]
}

output "addsservers_ip" {
  description = "adds Servers IP addresses."
  value       = ["${azurerm_network_interface.adds.*.private_ip_address}"]
}

output "mgtservers_name" {
  description = "mgt Servers names."
  value       = ["${azurerm_virtual_machine.mgt.*.name}"]
}

output "mgtservers_ip" {
  description = "App Servers IP addresses."
  value       = ["${azurerm_network_interface.mgt.*.private_ip_address}"]
}

output "LB_VIP_IP" {
  description = "Internet facing LB VIP."
  value       = ["${azurerm_public_ip.vip.ip_address}"]
}

output "LB_VIP_DNS" {
  description = "Internet facing LB DNS."
  value       = ["${azurerm_public_ip.vip.fqdn}"]
}
