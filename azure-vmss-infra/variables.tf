variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod)"
  default     = "stage"
}

variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed Azure locations"
  default     = ["East US", "West Europe", "Southeast Asia"]
}

variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "East US"

  validation {
    condition     = contains(var.allowed_locations, var.location)
    error_message = "Location must be one of the allowed locations."
  }
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource naming"
  default     = "vmss-lab"
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default = {
    environment = "Development"
    managed_by  = "DevOpsTeam"
    department  = "devops"
  }
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_prefixes" {
  type        = list(string)
  description = "Address prefixes for the application subnet"
  default     = ["10.0.1.0/24"]
}

variable "subnet_mgmt_prefixes" {
  type        = list(string)
  description = "Address prefixes for the management subnet"
  default     = ["10.0.2.0/24"]
}

variable "default_capacity" {
  type        = number
  description = "Default capacity for the virtual machine scale set"
  default     = 2
}

variable "min_capacity" {
  type        = number
  description = "Minimum capacity for the virtual machine scale set"
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "Maximum capacity for the virtual machine scale set"
  default     = 5
}

variable "cpu_scale_out_threshold" {
  type        = number
  description = "CPU threshold for scaling out"
  default     = 80
}

variable "cpu_scale_in_threshold" {
  type        = number
  description = "CPU threshold for scaling in"
  default     = 10
}

variable "scale_out_value" {
  type        = number
  description = "Number of instances to add when scaling out"
  default     = 1
}

variable "scale_in_value" {
  type        = number
  description = "Number of instances to remove when scaling in"
  default     = 1
}

variable "vmss_sku_by_env" {
  type        = map(string)
  description = "VMSS SKU per environment"
  default = {
    dev   = "Standard_B1s"
    stage = "Standard_B2s"
    prod  = "Standard_B2ms"
  }
}

variable "vmss_sku_default" {
  type        = string
  description = "Default VMSS SKU if environment is not in the map"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VMSS instances"
  default     = "vmssinfraadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key content (e.g., ssh-ed25519 AAAA...)"
}
