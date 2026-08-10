output "vnet_id" {
  description = "ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "gateway_subnet_id" {
  description = "ID of the GatewaySubnet."
  value       = azurerm_subnet.gateway.id
}

output "firewall_subnet_id" {
  description = "ID of the AzureFirewallSubnet."
  value       = azurerm_subnet.firewall.id
}

output "vpn_gateway_id" {
  description = "ID of the hub VPN gateway."
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the hub VPN gateway."
  value       = azurerm_public_ip.vpn_gateway.ip_address
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall, used as next hop by the spokes."
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall."
  value       = azurerm_public_ip.firewall.ip_address
}
