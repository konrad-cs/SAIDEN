output "resource_group_name" {
  description = "Name of the resource group holding the Azure resources."
  value       = azurerm_resource_group.main.name
}

output "hub_vnet_id" {
  description = "ID of the hub virtual network."
  value       = module.hub.vnet_id
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the hub VPN gateway (peer address for the Equinix LD4 router)."
  value       = module.hub.vpn_gateway_public_ip
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall used as the spoke next hop."
  value       = module.hub.firewall_private_ip
}

output "spoke_data_processing_vnet_id" {
  description = "ID of the Data Processing spoke virtual network."
  value       = module.spoke_data_processing.vnet_id
}

output "spoke_backtesting_vnet_id" {
  description = "ID of the Backtesting spoke virtual network."
  value       = module.spoke_backtesting.vnet_id
}

output "local_network_gateway_id" {
  description = "ID of the local network gateway representing the Equinix LD4 site."
  value       = azurerm_local_network_gateway.equinix_ld4.id
}
