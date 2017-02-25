output "servers_name" {
  description = "Server's names."
  value       = ["${azurerm_virtual_machine.tier1-vm.*.name}"]
}

output "servers_ip" {
  description = "Server's IP addresses."
  value       = ["${azurerm_network_interface.tier5-nics.private_ip_address}"]
}

output "LB_VIP_IP" {
  description = "Load Balancer IP address."
  value       = ["${azurerm_public_ip.lbIP.ip_address}"]
}

output "LB_VIP_DNS" {
  description = "Load Balancer DNS name."
  value       = ["${azurerm_public_ip.lbIP.fqdn}"]
}
