# variables.tf
variable "prefix" {
  description = "Short prefix used in resource names (change it to visualize replacement)."
  type        = string
  default     = "kbvault"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
  default     = "uat"
}

variable "storage_account_name" {
  description = "Must be globally unique, 3-24 chars, lowercase letters/numbers only."
  type        = string
}

variable "tags" {
  description = "Base tags. Some tags will be ignored via lifecycle.ignore_changes."
  type        = map(string)
  default = {
    owner = "platform"
  }
}
