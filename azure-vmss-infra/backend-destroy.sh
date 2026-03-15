#!/usr/bin/env bash
set -euo pipefail

############################################
# Logging helpers
############################################

log() {
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

step() {
  echo
  log "🔹 $1"
}

success() {
  log "✅ $1"
}

fail() {
  log "❌ $1"
  exit 1
}

############################################
# Configuration
############################################

RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-platform-tfstate}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:-}"

############################################
# Preconditions
############################################

step "Checking prerequisites"

command -v az >/dev/null 2>&1 || fail "Azure CLI (az) not installed."
command -v jq >/dev/null 2>&1 || fail "jq is required."

for var in ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID ARM_SUBSCRIPTION_ID; do
  [[ -z "${!var:-}" ]] && fail "Missing required environment variable: $var"
done

success "Prerequisites validated"

############################################
# Azure authentication
############################################

step "Authenticating with Azure Service Principal"

az login \
  --service-principal \
  --username "$ARM_CLIENT_ID" \
  --password "$ARM_CLIENT_SECRET" \
  --tenant "$ARM_TENANT_ID" \
  --output none

az account set --subscription "$ARM_SUBSCRIPTION_ID"

ACTIVE_SUB=$(az account show --query id -o tsv)
ACTIVE_NAME=$(az account show --query name -o tsv)

success "Authenticated to subscription"
log "Subscription ID : $ACTIVE_SUB"
log "Subscription Name: $ACTIVE_NAME"

############################################
# Discover storage accounts if not provided
############################################

step "Resolving storage account"

if [[ -z "$STORAGE_ACCOUNT_NAME" ]]; then

  mapfile -t ACCOUNTS < <(
    az storage account list \
      --resource-group "$RESOURCE_GROUP_NAME" \
      --query "[].name" \
      -o tsv
  )

  [[ ${#ACCOUNTS[@]} -eq 0 ]] && fail "No storage accounts found in $RESOURCE_GROUP_NAME"

  echo
  log "Available storage accounts:"
  echo "---------------------------------"

  for i in "${!ACCOUNTS[@]}"; do
    printf "%d) %s\n" "$((i+1))" "${ACCOUNTS[$i]}"
  done

  echo
  read -rp "Select storage account number: " IDX

  [[ ! "$IDX" =~ ^[0-9]+$ ]] && fail "Invalid selection"

  STORAGE_ACCOUNT_NAME="${ACCOUNTS[$((IDX-1))]}"
fi

[[ -z "$STORAGE_ACCOUNT_NAME" ]] && fail "Storage account name is empty"

success "Storage account selected"
log "Storage Account: $STORAGE_ACCOUNT_NAME"

############################################
# Confirm destruction
############################################

echo
read -rp "⚠️  This will delete storage account '$STORAGE_ACCOUNT_NAME'. Continue? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  fail "Operation cancelled"
fi

############################################
# Destroy storage account
############################################

step "Deleting storage account (containers will be deleted automatically)"

az storage account delete \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --yes

success "Storage account deleted"

############################################
# Final summary
############################################

echo
log "🧹 Terraform backend resources cleaned"
echo "--------------------------------------"
echo "Resource Group (kept): $RESOURCE_GROUP_NAME"
echo "Deleted Storage      : $STORAGE_ACCOUNT_NAME"
echo