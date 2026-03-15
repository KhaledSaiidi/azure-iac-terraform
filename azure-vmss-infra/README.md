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

## CI/CD (GitHub Actions)

This project is deployed via `.github/workflows/azure-vmss-infra.yml`.

**Triggers**
- `push` to `main` when `azure-vmss-infra/assets/index.php` changes (plan runs, deploy/destroy are skipped by default).
- Manual `workflow_dispatch` with a dropdown to select the Terraform action.

**Manual Run Actions**
- `tf_action = deploy`: runs `terraform apply` using the saved plan.
- `tf_action = destroy`: runs `terraform destroy`.
- `tf_action = none`: skips deploy/destroy after the plan.

**Required GitHub Secrets**
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `GH_TOKEN`
- `SSH_PUBLIC_KEY` (full public key line, e.g., `ssh-ed25519 AAAA... user@host`)

The workflow passes `SSH_PUBLIC_KEY` into Terraform as `TF_VAR_ssh_public_key`.

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

## How It Works (Automated CI/CD)

This project is designed to be run via GitHub Actions. The workflow plans on push and lets you manually deploy or destroy after reviewing the plan.

## CI/CD Flow

1. **Set GitHub Secrets** (required):
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`
   - `GH_TOKEN`
   - `SSH_PUBLIC_KEY` (full public key line, e.g., `ssh-ed25519 AAAA... user@host`)

2. **Trigger a plan** by pushing a change to `azure-vmss-infra/assets/index.php`.
   - The workflow runs `terraform init` and `terraform plan`.
   - `tf_action` defaults to `none`, so no apply/destroy happens automatically.

3. **Review the plan** in the Actions logs.

4. **Manual deploy or destroy** (optional):
   - Go to **Actions → Azure VMSS Infrastructure Deployment → Run workflow**.
   - Choose `tf_action = deploy` to apply the plan.
   - Choose `tf_action = destroy` to destroy the stack.
   - Choose `tf_action = none` to plan only.

## Notes

- **No availability zones are pinned** to avoid region‑specific failures. Add zones only when targeting regions with verified support.
- **Bastion SSH is open to the internet** by default. For production use, restrict the source CIDR.
- **User data fetches an external file** from GitHub. For fully deterministic builds, inline the file or host it in trusted storage.
