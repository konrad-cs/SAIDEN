variable "name_prefix" {
  description = "Naming prefix applied to the spoke resources."
  type        = string
}

variable "spoke_name" {
  description = "Short name of the spoke (e.g. data-processing)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group holding the spoke resources."
  type        = string
}

variable "location" {
  description = "Azure region of the spoke resources."
  type        = string
}

variable "address_space" {
  description = "Address space of the spoke virtual network."
  type        = list(string)
}

variable "workload_subnet_prefixes" {
  description = "Address prefixes of the workload subnet."
  type        = list(string)
}

variable "hub_vnet_id" {
  description = "ID of the hub virtual network to peer with."
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network to peer with."
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource group of the hub virtual network."
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP address of the hub firewall, used as the next hop of the spoke route table."
  type        = string
}

variable "routed_address_prefixes" {
  description = "Address prefixes routed through the hub firewall."
  type        = list(string)
  default     = ["0.0.0.0/0", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "hub_vpn_gateway_id" {
  description = "ID of the hub VPN gateway. Referenced by the peerings so that the gateway exists before gateway transit is enabled."
  type        = string
}

variable "tags" {
  description = "Tags applied to the spoke resources."
  type        = map(string)
  default     = {}
}
