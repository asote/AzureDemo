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

output "LB_VIP_IP" {
  description = "Internet facing LB VIP."
  value       = ["${azurerm_public_ip.vip.ip_address}"]
}

output "LB_VIP_DNS" {
  description = "Internet facing LB DNS."
  value       = ["${azurerm_public_ip.vip.fqdn}"]
}
