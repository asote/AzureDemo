output "webservers_name" {
  value = ["${azurerm_virtual_machine.web.*.name}"]
}

output "webservers_ip" {
  value = ["${azurerm_network_interface.public.*.private_ip_address}"]
}

output "LB_VIP_IP" {
  value = ["${azurerm_public_ip.vip.ip_address}"]
}

output "LB_VIP_DNS" {
  value = ["${azurerm_public_ip.vip.fqdn}"]
}
