# Azure VMSS Infrastructure (Terraform)

Build a scalable web tier on Azure with a load‑balanced VM Scale Set, autoscaling, and a dedicated jump host in a management subnet. The stack is designed to be environment‑aware and safe by default for production‑like deployments.

![Architecture diagram](assets/diagram.png)

## Architecture Overview

**Resource group**
- Single resource group per environment with enforced location validation.

**Networking**
- VNet with two subnets:
  - `app` subnet: hosts the VMSS.
  - `mgmt` subnet: hosts the bastion jump host.
- NSG on the `app` subnet only:
  - Allows inbound HTTP/HTTPS **from Azure Load Balancer**.
  - Denies all other inbound traffic.
- NAT gateway on the `app` subnet for outbound internet access.
- Management subnet is intentionally **not** bound to the app NSG.

**Load Balancer**
- Standard public Load Balancer with:
  - Public IP.
  - Backend pool attached to the VMSS.
  - HTTP health probe on port 80.
  - LB rules generated from locals (data‑driven).

**Compute**
- **VMSS (app tier)**:
  - Ubuntu 22.04 LTS (Jammy).
  - SKU based on environment (`dev`, `stage`, `prod`).
  - Autoscaling based on CPU thresholds.
  - Cloud‑init user data installs Apache/PHP and renders instance metadata.
- **Bastion (jump host)**:
  - Ubuntu 20.04 LTS (Focal).
  - Small VM size (`Standard_B1s`).
  - Public IP and SSH‑only access.
  - Placed in the `mgmt` subnet.

## Repository Layout

- `provider.tf`: Terraform and provider versions.
- `variables.tf`: Inputs and validation.
- `locals.tf`: Naming, tags, and data‑driven rules.
- `vnet.tf`: Resource group, VNet, subnets, NSG, LB, NAT gateway.
- `vmss.tf`: VM Scale Set configuration.
- `autoscale.tf`: Autoscale settings for VMSS.
- `bastion.tf`: Jump host VM, NIC, NSG, and public IP.
- `backend.tf`: Remote state backend configuration.
- `backend.sh`: Script to bootstrap the state backend.
- `user-data.sh`: App tier cloud‑init content.

## Inputs

Core variables (see `variables.tf`):
- `environment`: `dev` | `stage` | `prod`
- `location`: `East US` | `West Europe` | `Southeast Asia` (validated)
- `resource_prefix`: base name for resources
- `ssh_public_key`: SSH public key **content** (e.g., `ssh-ed25519 AAAA...`)
- `default_capacity`, `min_capacity`, `max_capacity`: VMSS sizing
- `cpu_scale_in_threshold`, `cpu_scale_out_threshold`: autoscale thresholds
- `vnet_address_space`, `subnet_app_prefixes`, `subnet_mgmt_prefixes`

### Example `terraform.tfvars`

```hcl
environment        = "stage"
location           = "East US"
resource_prefix    = "vmss-lab"
ssh_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF..."
default_capacity   = 2
min_capacity       = 2
max_capacity       = 5
vnet_address_space = ["10.0.0.0/16"]
subnet_app_prefixes  = ["10.0.1.0/24"]
subnet_mgmt_prefixes = ["10.0.2.0/24"]
```

## How It Works

- **Inbound web traffic** hits the public Load Balancer.
- **LB health probe** checks `/` on port `80`.
- **NSG** allows only LB‑originated HTTP/HTTPS to the app subnet.
- **VMSS** instances serve a basic web page (metadata dumped to `index.html`).
- **Autoscale** adds/removes instances based on CPU.
- **Bastion** provides SSH access for management via its public IP.

## Notes

- **No availability zones are pinned** to avoid region‑specific failures. Add zones only when targeting regions with verified support.
- **Bastion SSH is open to the internet** by default. For production use, restrict the source CIDR.
- **User data fetches an external file** from GitHub. For fully deterministic builds, inline the file or host it in trusted storage.

## Quick Start

1. Initialize and validate:
```bash
terraform init
terraform validate
```

2. Plan and apply:
```bash
terraform plan
terraform apply
```

3. Bastion access:
```bash
ssh -i /path/to/private_key ${ADMIN_USERNAME}@<bastion_public_ip>
```

Replace `${ADMIN_USERNAME}` with `admin_username` and `<bastion_public_ip>` with the created IP.
