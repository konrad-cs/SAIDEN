terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

locals {
  spoke_prefix = "${var.name_prefix}-${var.spoke_name}"
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${local.spoke_prefix}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  name                 = "${local.spoke_prefix}-workload-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = var.workload_subnet_prefixes
}

# All spoke egress (including spoke-to-spoke traffic) is forced through the hub firewall.
resource "azurerm_route_table" "spoke" {
  name                = "${local.spoke_prefix}-rt"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_route" "firewall" {
  for_each = toset(var.routed_address_prefixes)

  name                   = "to-hub-firewall-${replace(replace(each.value, ".", "-"), "/", "_")}"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${local.spoke_prefix}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  lifecycle {
    # Referencing the hub gateway makes it a dependency, so the peering is only
    # created once the gateway it transits through exists.
    precondition {
      condition     = var.hub_vpn_gateway_id != ""
      error_message = "hub_vpn_gateway_id must be provided so the spoke peering can use the hub gateway."
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${local.spoke_prefix}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  lifecycle {
    precondition {
      condition     = var.hub_vpn_gateway_id != ""
      error_message = "hub_vpn_gateway_id must be provided before gateway transit can be enabled on the hub peering."
    }
  }
}
