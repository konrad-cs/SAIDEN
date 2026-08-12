variable "location" {
  description = "Azure region in which all resources are created."
  type        = string
  default     = "northeurope"
}

variable "prefix" {
  description = "Short naming prefix applied to every resource name."
  type        = string
  default     = "saiden"
}

variable "environment" {
  description = "Environment name (e.g. prod, dev) used in resource naming."
  type        = string
  default     = "prod"
}

variable "resource_group_name" {
  description = "Name of the resource group holding the Azure resources. Defaults to \"<prefix>-<environment>-rg\" when null."
  type        = string
  default     = null
}

variable "hub_address_space" {
  description = "Address space of the hub virtual network."
  type        = list(string)
  default     = ["10.16.0.0/16"]
}

variable "gateway_subnet_prefixes" {
  description = "Address prefixes of the hub GatewaySubnet."
  type        = list(string)
  default     = ["10.16.0.0/24"]
}

variable "firewall_subnet_prefixes" {
  description = "Address prefixes of the hub AzureFirewallSubnet."
  type        = list(string)
  default     = ["10.16.1.0/24"]
}

variable "spoke_data_processing_address_space" {
  description = "Address space of the Data Processing spoke virtual network (Link 1)."
  type        = list(string)
  default     = ["10.17.0.0/16"]
}

variable "spoke_data_processing_workload_prefixes" {
  description = "Address prefixes of the Data Processing workload subnet."
  type        = list(string)
  default     = ["10.17.0.0/24"]
}

variable "spoke_backtesting_address_space" {
  description = "Address space of the Backtesting spoke virtual network (Link 2)."
  type        = list(string)
  default     = ["10.18.0.0/16"]
}

variable "spoke_backtesting_workload_prefixes" {
  description = "Address prefixes of the Backtesting workload subnet."
  type        = list(string)
  default     = ["10.18.0.0/24"]
}

variable "vpn_gateway_sku" {
  description = "SKU of the hub VPN gateway."
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

variable "onprem_address_space" {
  description = "On-premises address spaces reachable over the IPSec tunnel. DUB-O (10.1.0.0/16) is only reachable indirectly through the Equinix router/fiber link."
  type        = list(string)
  default     = ["10.2.0.0/16", "10.1.0.0/16"]
}

variable "equinix_router_public_ip" {
  description = "Public IP address of the Equinix LD4 router terminating the IPSec tunnel to Azure."
  type        = string
}

variable "vpn_shared_key" {
  description = "Pre-shared key of the IPSec site-to-site connection to the Equinix LD4 router."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
