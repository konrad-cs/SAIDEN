terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}-hub-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet names for the gateway and the firewall are fixed by the Azure platform.
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.gateway_subnet_prefixes
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.firewall_subnet_prefixes
}

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "${var.name_prefix}-vpngw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# IPSec termination point for the tunnel back to the Equinix LD4 router.
resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "${var.name_prefix}-vpngw"
  resource_group_name = var.resource_group_name
  location            = var.location

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = var.vpn_gateway_sku

  active_active = false
  enable_bgp    = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  tags = var.tags
}

resource "azurerm_public_ip" "firewall" {
  name                = "${var.name_prefix}-fw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "hub" {
  name                = "${var.name_prefix}-fw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.firewall_sku_tier
  tags                = var.tags
}

# Allow the spokes to reach the on-premises sites (and each other) through the hub.
resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  name               = "${var.name_prefix}-fw-rules"
  firewall_policy_id = azurerm_firewall_policy.hub.id
  priority           = 500

  network_rule_collection {
    name     = "internal-traffic"
    priority = 500
    action   = "Allow"

    rule {
      name                  = "spoke-to-onprem-and-spoke"
      protocols             = ["Any"]
      source_addresses      = ["10.16.0.0/12"]
      destination_addresses = ["10.16.0.0/12", "10.2.0.0/16", "10.1.0.0/16"]
      destination_ports     = ["*"]
    }

    rule {
      name                  = "onprem-to-spoke"
      protocols             = ["Any"]
      source_addresses      = ["10.2.0.0/16", "10.1.0.0/16"]
      destination_addresses = ["10.16.0.0/12"]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall" "hub" {
  name                = "${var.name_prefix}-fw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.hub.id

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.tags
}
