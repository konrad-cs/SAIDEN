# Architecture

<img width="1916" height="1196" alt="image" src="https://github.com/user-attachments/assets/420e7581-e7b5-4ac9-8219-a9e90ef86e60" />

## Terraform

This repository contains the Terraform configuration that models the Azure side of
the architecture above: a hub-and-spoke virtual network in the `10.16.0.0/12`
supernet, connected back to the Equinix LD4 colocation site over an IPSec
site-to-site VPN.

The Equinix LD4 (`10.2.0.0/16`) and DUB-O (`10.1.0.0/16`) sites are physical
colocation/on-premises infrastructure and are therefore not provisioned by
Terraform. They are represented only by the local network gateway and the VPN
connection that define the network boundary. DUB-O has no tunnel of its own to
Azure - it is reachable indirectly through the Equinix router and the fiber link,
so its address space is included in the Equinix local network gateway.

### Layout

| Path | Purpose |
| --- | --- |
| `versions.tf` | Required Terraform/`azurerm` provider versions and the provider block. |
| `variables.tf` | Input variables (location, naming, address spaces, SKUs, VPN peer settings, tags). |
| `main.tf` | Resource group, hub module, both spoke modules, local network gateway and VPN connection. |
| `outputs.tf` | Hub VNet ID, VPN gateway public IP, spoke VNet IDs, firewall private IP. |
| `terraform.tfvars.example` | Example values for every variable (placeholders only for secrets). |
| `modules/hub-network` | Hub VNet (`10.16.0.0/16`) with `GatewaySubnet` and `AzureFirewallSubnet`, route-based VPN gateway and Azure Firewall + firewall policy. |
| `modules/spoke-network` | Parameterised spoke VNet with a workload subnet, bi-directional peering to the hub (gateway transit) and a UDR sending traffic to the hub firewall. |

The spoke module is instantiated twice:

- **Spoke 1 ("Link 1")** - Data Processing, `10.17.0.0/16`
- **Spoke 2 ("Link 2")** - Backtesting, `10.18.0.0/16`

Spokes have no peering with each other; all inter-spoke and on-premises traffic is
forced through the hub firewall by the spoke route tables.

### Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars - supply the Equinix router public IP and the VPN shared key

terraform init
terraform plan
terraform apply
```

Secrets must never be committed. Supply `vpn_shared_key` through an untracked
`terraform.tfvars`, the `TF_VAR_vpn_shared_key` environment variable, or a secret
store.
