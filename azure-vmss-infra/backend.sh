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
LOCATION="${LOCATION:-eastus}"
CONTAINER_NAME="${CONTAINER_NAME:-tfstate001}"

if [[ -z "${STORAGE_ACCOUNT_NAME:-}" ]]; then
  STORAGE_ACCOUNT_NAME="platengtfstate$(date +%s)"
fi

############################################
# Preconditions
############################################

step "Checking prerequisites"

command -v az >/dev/null 2>&1 || fail "Azure CLI (az) not installed."

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
# Validate storage name
############################################

step "Validating storage account name"

[[ ${#STORAGE_ACCOUNT_NAME} -lt 3 || ${#STORAGE_ACCOUNT_NAME} -gt 24 ]] \
  && fail "STORAGE_ACCOUNT_NAME must be 3-24 characters."

[[ ! "$STORAGE_ACCOUNT_NAME" =~ ^[a-z0-9]+$ ]] \
  && fail "STORAGE_ACCOUNT_NAME must contain only lowercase letters and numbers."

success "Storage account name validated"

############################################
# Resource creation
############################################

step "Creating resource group"

RG_JSON=$(az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION")

RG_ID=$(echo "$RG_JSON" | jq -r '.id')

success "Resource group ready"
log "Resource Group: $RESOURCE_GROUP_NAME"
log "Resource ID  : $RG_ID"

############################################

step "Creating storage account"

SA_JSON=$(az storage account create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$STORAGE_ACCOUNT_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2)

SA_ID=$(echo "$SA_JSON" | jq -r '.id')

success "Storage account created"
log "Storage Account: $STORAGE_ACCOUNT_NAME"
log "Resource ID    : $SA_ID"

############################################

step "Creating blob container"

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --auth-mode login \
  --output none

success "Blob container created"
log "Container: $CONTAINER_NAME"

############################################
# Final summary
############################################

echo
log "🎉 Terraform backend infrastructure ready"
echo "------------------------------------------"
echo "Resource Group  : $RESOURCE_GROUP_NAME"
echo "Storage Account : $STORAGE_ACCOUNT_NAME"
echo "Container       : $CONTAINER_NAME"
echo "Location        : $LOCATION"
echo