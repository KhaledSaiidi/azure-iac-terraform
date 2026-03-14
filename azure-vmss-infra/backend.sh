#!/bin/bash
set -euo pipefail

RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-platform-tfstate}"
LOCATION="${LOCATION:-eastus}"
CONTAINER_NAME="${CONTAINER_NAME:-tfstate001}"

if [[ -z "${STORAGE_ACCOUNT_NAME:-}" ]]; then
  STORAGE_ACCOUNT_NAME="platengtfstate$RANDOM"
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) not found. Install it before running this script."
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Not logged in to Azure. Run: az login"
  exit 1
fi

if [[ ${#STORAGE_ACCOUNT_NAME} -lt 3 || ${#STORAGE_ACCOUNT_NAME} -gt 24 ]]; then
  echo "STORAGE_ACCOUNT_NAME must be 3-24 characters."
  exit 1
fi

if [[ ! "$STORAGE_ACCOUNT_NAME" =~ ^[a-z0-9]+$ ]]; then
  echo "STORAGE_ACCOUNT_NAME must be lowercase letters and numbers only."
  exit 1
fi

echo "Using resource group: $RESOURCE_GROUP_NAME"
echo "Using location:       $LOCATION"
echo "Using storage acct:   $STORAGE_ACCOUNT_NAME"
echo "Using container:      $CONTAINER_NAME"

az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --output none

az storage account create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$STORAGE_ACCOUNT_NAME" \
  --sku Standard_LRS \
  --encryption-services blob \
  --output none

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --auth-mode login \
  --output none

echo "Backend ready."
