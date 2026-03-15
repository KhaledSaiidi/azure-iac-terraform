# azure-iac-terraform

Infrastructure-as-Code for Azure using Terraform. This repo started as a learning space (`azure-utils`) and is evolving into a set of independent, fully automated infrastructure projects with GitHub Actions.

## Repository Structure

- `azure-utils`: Quick reminders and focused examples for Terraform-on-Azure concepts.
- `azure-vmss-infra`: A complete VM Scale Set infrastructure project with automated CI/CD (plan, deploy, destroy) via GitHub Actions to deploy a mini-game on Azure in an automated way.

## Projects

### azure-vmss-infra

A platform‑engineer‑style, end‑to‑end VMSS stack (VNet, subnets, NSGs, LB, NAT, autoscale, bastion) built for safe, repeatable delivery:

- **Composable infrastructure**: clear module boundaries by file and data‑driven locals for predictable naming and policies.
- **Change safety**: plan runs on every push that touches the app asset, with a saved plan artifact before any apply.
- **Controlled promotion**: apply/destroy are manual and explicit via `tf_action`, avoiding accidental production changes.
- **Operational clarity**: logs summarize what changes and why, so reviews are fast and auditable.

The workflow `.github/workflows/azure-vmss-infra.yml` supports:

- Automatic plan on push when `azure-vmss-infra/assets/index.php` changes.
- Manual runs with `tf_action` dropdown:
  - `deploy`: apply from the saved plan.
  - `destroy`: destroy the stack.
  - `none`: plan only, skip apply/destroy.

See `azure-vmss-infra/README.md` for full architecture, inputs, and usage.
