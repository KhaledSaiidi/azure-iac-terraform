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

variable "default_capacity" {
  type        = number
  description = "Default capacity for the virtual machine scale set"
  default     = 2
}

variable "min_capacity" {
  type        = number
  description = "Minimum capacity for the virtual machine scale set"
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "Maximum capacity for the virtual machine scale set"
  default     = 5
}

variable cpu_threshold {
  type        = number
  description = "CPU threshold for autoscaling"
  default     = 75
}

variable scale_out_value {
  type        = number
  description = "Number of instances to add when scaling out"
  default     = 1
}

variable scale_in_value {
  type        = number
  description = "Number of instances to remove when scaling in"
  default     = 1
}