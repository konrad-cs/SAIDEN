output "vnet_id" {
  description = "ID of the spoke virtual network."
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Name of the spoke virtual network."
  value       = azurerm_virtual_network.spoke.name
}

output "workload_subnet_id" {
  description = "ID of the workload subnet."
  value       = azurerm_subnet.workload.id
}

output "route_table_id" {
  description = "ID of the route table forcing traffic through the hub firewall."
  value       = azurerm_route_table.spoke.id
}
