locals {
  name_prefix         = "${var.prefix}-${var.environment}"
  resource_group_name = coalesce(var.resource_group_name, "${var.prefix}-${var.environment}-rg")

  tags = merge(
    {
      environment = var.environment
      workload    = "saiden-trading-platform"
      managed_by  = "terraform"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# Hub virtual network: VPN gateway (IPSec termination for Equinix LD4) and Azure Firewall.
module "hub" {
  source = "./modules/hub-network"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space            = var.hub_address_space
  gateway_subnet_prefixes  = var.gateway_subnet_prefixes
  firewall_subnet_prefixes = var.firewall_subnet_prefixes

  vpn_gateway_sku   = var.vpn_gateway_sku
  firewall_sku_name = var.firewall_sku_name
  firewall_sku_tier = var.firewall_sku_tier

  spoke_address_spaces = concat(
    var.spoke_data_processing_address_space,
    var.spoke_backtesting_address_space,
  )
  onprem_address_space = var.onprem_address_space

  tags = local.tags
}

# Spoke 1 ("Link 1"): Data Processing workload.
module "spoke_data_processing" {
  source = "./modules/spoke-network"

  name_prefix = local.name_prefix
  spoke_name  = "data-processing"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space            = var.spoke_data_processing_address_space
  workload_subnet_prefixes = var.spoke_data_processing_workload_prefixes

  hub_vnet_id             = module.hub.vnet_id
  hub_vnet_name           = module.hub.vnet_name
  hub_resource_group_name = azurerm_resource_group.main.name
  hub_vpn_gateway_id      = module.hub.vpn_gateway_id
  firewall_private_ip     = module.hub.firewall_private_ip

  tags = local.tags
}

# Spoke 2 ("Link 2"): Backtesting workload.
module "spoke_backtesting" {
  source = "./modules/spoke-network"

  name_prefix = local.name_prefix
  spoke_name  = "backtesting"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space            = var.spoke_backtesting_address_space
  workload_subnet_prefixes = var.spoke_backtesting_workload_prefixes

  hub_vnet_id             = module.hub.vnet_id
  hub_vnet_name           = module.hub.vnet_name
  hub_resource_group_name = azurerm_resource_group.main.name
  hub_vpn_gateway_id      = module.hub.vpn_gateway_id
  firewall_private_ip     = module.hub.firewall_private_ip

  tags = local.tags
}

# Network boundary of the physical Equinix LD4 colocation site. DUB-O (10.1.0.0/16)
# is only reachable indirectly, through the Equinix router and the fiber link.
resource "azurerm_local_network_gateway" "equinix_ld4" {
  name                = "${local.name_prefix}-equinix-ld4-lng"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  gateway_address = var.equinix_router_public_ip
  address_space   = var.onprem_address_space

  tags = local.tags
}

resource "azurerm_virtual_network_gateway_connection" "equinix_ld4" {
  name                = "${local.name_prefix}-equinix-ld4-conn"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type                       = "IPsec"
  connection_protocol        = "IKEv2"
  virtual_network_gateway_id = module.hub.vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.equinix_ld4.id

  shared_key = var.vpn_shared_key

  tags = local.tags
}
