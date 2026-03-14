variable "environment" {
  type        = string
  description = "the env type"
  default     = "staging"
}

variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed Azure locations"
  default     = ["East US", "West Europe", "Southeast Asia"]
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default = {
    environment = "Development"
    managed_by  = "DevOpsTeam"
    departement = "devops"
  }
}

variable "network_config" {
  type        = list(string)
  description = "List of address spaces for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "address_prefixes" {
  type        = list(string)
  description = "List of address spaces for the virtual network"
  default     = ["10.0.0.0/20"]
}