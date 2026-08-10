variable "name_prefix" {
  description = "Naming prefix applied to the hub resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group holding the hub resources."
  type        = string
}

variable "location" {
  description = "Azure region of the hub resources."
  type        = string
}

variable "address_space" {
  description = "Address space of the hub virtual network."
  type        = list(string)
}

variable "gateway_subnet_prefixes" {
  description = "Address prefixes of the GatewaySubnet."
  type        = list(string)
}

variable "firewall_subnet_prefixes" {
  description = "Address prefixes of the AzureFirewallSubnet."
  type        = list(string)
}

variable "vpn_gateway_sku" {
  description = "SKU of the VPN gateway."
  type        = string
  default     = "VpnGw1"
}

variable "firewall_sku_name" {
  description = "SKU name of the Azure Firewall."
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  description = "SKU tier of the Azure Firewall."
  type        = string
  default     = "Standard"
}

variable "spoke_address_spaces" {
  description = "Address spaces of the spoke virtual networks allowed to transit the firewall."
  type        = list(string)
  default     = []
}

variable "onprem_address_space" {
  description = "On-premises address spaces reachable over the IPSec tunnel."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the hub resources."
  type        = map(string)
  default     = {}
}
